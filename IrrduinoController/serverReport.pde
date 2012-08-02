// This code is adapted by Joe Fernandez from PollingDNS.pde which is:
//
//  Copyright (C) 2010 Georg Kaindl
//  http://gkaindl.com
//
//  This file is part of Arduino EthernetDNS.
//
//  EthernetDNS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as
//  published by the Free Software Foundation, either version 3 of
//  the License, or (at your option) any later version.
//
//  EthernetDNS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with EthernetDNS. If not, see
//  <http://www.gnu.org/licenses/>.
//
// The code written by Joe Fernandez is:
//
// Copyright 2012 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const char* ip_to_str(const uint8_t*);

// TODO: Populate reportData for reporting to IrrduinoServer
// /reports?zone=1&runtime=120";
void checkAndPostReport(){

    if (commandReport[CR_ZONE_ID] > 0){
        reportData  = "/log?zone=";
        reportData += commandReport[CR_ZONE_ID];
        reportData += "&runtime=";

        // calculate runtime in seconds
        reportData += (commandReport[CR_END_TIME] - commandReport[CR_START_TIME]) / 1000;
        
        Serial.println("Run Report parameters set:");
        Serial.println(reportData);
    }
  
    if (reportData != ""){
      // there is report data waiting to be sent
      
      // make sure we are not sending reports endlessly
      if (reportAttempts >= maxReportAttempts) {
         reportData = "";
         clearCommandReport();
         reportAttempts = 0;
      } else {
         reportAttempts++;
      }
          

      byte ipAddr[4];

      DNSError err = EthernetDNS.resolveHostName(reportingHostName, ipAddr);

      if (DNSSuccess == err) {
        Serial.print("The IP address is: ");
        Serial.println(ip_to_str(ipAddr));
      } else if (DNSTimedOut == err) {
        Serial.println("Timed out.");
      } else if (DNSNotFound == err) {
        Serial.println("Does not exist.");
      } else {
        Serial.print("Failed with error code ");
        Serial.print((int)err, DEC);
        Serial.println(".");
      }
      
      Client client(ipAddr, reportingHostPort);
      
     if (client.connect()) {
       Serial.print("Sending report data: ");
       Serial.println(reportData);
       
       
       client.print("POST ");
       client.print(reportData);
       client.println(" HTTP/1.1");
       client.print("Host: ");
       client.println(reportingHostName);
       client.println("Content-length: 0");
       client.println(""); // required to complete the request
       
       // TODO: check the return message for result
       
       // empty the reportData and clear the commandReport object
       reportData = "";
       clearCommandReport();
     } 
     else {
       Serial.println("connection failed");
     }
  
     // give the server time to receive the data
     delay(20);
     client.stop();
  }
}

// Just a utility function to nicely format an IP address.
const char* ip_to_str(const uint8_t* ipAddr) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}

// process a test report of the format:
// /testreport/testserver.org:8080/datadrop?what=1&ever=2&you=3&want=4
void testReport(char* urlLocation){
    
    String location = String(urlLocation);
    Serial.print("location: ");
    Serial.println(location);

    int testReportLength = REST_CMD_TESTREPORT.length() + 2;
    
    //  find the testreport host name
    int endOfHost = location.indexOf(':', testReportLength); // start of port number
    if (endOfHost < 0){
      endOfHost = location.indexOf('/', testReportLength); // start of page
    }
    if (endOfHost < 0){
      endOfHost = location.indexOf('?', testReportLength); // start of parameters
    }
    Serial.print("endOfHost: ");
    Serial.println(endOfHost);
    if (endOfHost < 0) return;
    
    String reportHost = location.substring( testReportLength, endOfHost );
    Serial.print("reportHost: ");
    Serial.println(reportHost);

    reportHost.toCharArray(reportingHostName, BUFSIZE);
    
    reportData = location.substring( endOfHost, location.length());
    Serial.print("reportData: ");
    Serial.println(reportData);
}

