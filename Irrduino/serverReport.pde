// This code is adapted from by Joe Fernandez from PollingDNS.pde which is:

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

char reportServerHostName[512];

const char* ip_to_str(const uint8_t*);

void checkAndPostReport(){
  
    if (reportData != ""){
      // there is report data waiting to be sent
      
      byte ipAddr[4];
  
      DNSError err = EthernetDNS.resolveHostName(reportServerHostName, ipAddr);
  
      if (DNSSuccess == err) {
        Serial.print("The IP address is ");
        Serial.print(ip_to_str(ipAddr));
        Serial.println(".");
      } else if (DNSTimedOut == err) {
        Serial.println("Timed out.");
      } else if (DNSNotFound == err) {
        Serial.println("Does not exist.");
      } else {
        Serial.print("Failed with error code ");
        Serial.print((int)err, DEC);
        Serial.println(".");
      }
      
      Client client(ipAddr, 80);
      
     if (client.connect()) {
       Serial.println("connected");
       Serial.print("Sending report data: ");
       Serial.println(reportData);
       
       
       client.print("POST ");
       client.print(reportData);
       client.println(" HTTP/1.1");
       
       reportData = "";
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

// process a test report of the format: /testreport/irrduinoserver.org:8080/datadrop?what=1&ever=2&you=3&want=4
void testReport(char* urlLocation){
    
    String location = String(urlLocation);
    Serial.print("location: ");
    Serial.println(location);

    //  find the testreport host name
    int endOfHost = location.indexOf(':', CMD_TESTREPORT.length() + 2); // start of port number
    if (endOfHost < 0){
      endOfHost = location.indexOf('/', CMD_TESTREPORT.length() + 2); // start of page
    }
    if (endOfHost < 0){
      endOfHost = location.indexOf('?', CMD_TESTREPORT.length() + 2 ); // start of parameters
    }
    Serial.print("endOfHost: ");
    Serial.println(endOfHost);
    if (endOfHost < 0) return;
    
    String reportHost = location.substring( CMD_TESTREPORT.length() + 2, endOfHost );
    Serial.print("reportHost: ");
    Serial.println(reportHost);

    reportHost.toCharArray(reportServerHostName, BUFSIZE);
    
    reportData = location.substring( endOfHost, location.length());
    Serial.print("reportData: ");
    Serial.println(reportData);
}

