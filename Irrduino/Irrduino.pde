 /**
  Irrduino v0.8 by Joe Fernandez

  Issues:
  - need a nanny process to set a max run time for valves (regardless of commands or program)
  - add a "status" option for each zone individually
  - add sending event reports to web server for reporting

  Change Log:
  - 2011-12-13 - adding REST command for system settings /settings?rr
  - 2011-12-02 - added function to report zone runs checkAndPostReport()
  - 2011-12-02 - add per-zone status reporting, with zone IDs and remaining times
  - 2011-11-10 - add global status option
  - 2011-10-27 - added code to turn on and blink an LED on pin 13 while zone running
  - 2011-10-07 - fixed problem with home page not displaying after first request
               - fixed problem mismatch between zone/pin selection
  - 2011-10-05 - Version 0.6 completed
               - 3 file split, commandDispatch[] infrastructure implemented
               - fixed problem with zone command being run repeatedly
  - 2011-09-28 - Split pde into parts for easier code management
               - Introduced new commandDispatch[] object for storing command parameters
  - 2011-09-25 - Added web UI for more zones and "ALL OFF" function
  - 2011-09-xx - Entended parser to turn off zones indifvidually
  - updated to use timer for executing irrigation zone runs; now runs can be interrupted

  An irrigation control program with a REST-like http
  remote control protocol.

  Based on David A. Mellis's "Web Server" ethernet
  shield example sketch.

  REST implementation based on "RESTduino" sketch
  by Jason J. Gullickson
 */

#include <SPI.h>
#include <Ethernet.h>
#include <EthernetDNS.h>


byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x50, 0xA0 };    //physical mac address
byte ip[] = { 192, 168, 1, 14 };			// ip in lan
byte gateway[] = { 192, 168, 1, 1 };			// internet access via router
byte dnsServerIp[] = { 192, 168, 1, 1};                 // DNS server IP (typically your gateway)
byte subnet[] = { 255, 255, 255, 0 };                   //subnet mask

Server server(80);                                      //server port
Client client = NULL;                                   // client

// zone to pin mapping
int zone1 = 2; //pin 2
int zone2 = 3; //pin 3
int zone3 = 4; //pin 4
int zone4 = 5; //pin 5
int zone5 = 6; //pin 6
int zone6 = 7; //pin 7
int zone7 = 8; //pin 8
int zone8 = 9; //pin 9
int zone9 = 11; //pin 11
int zone10 = 12; //pin 12

// LED indicator pin variables
int ledIndicator = 13;
int ledState = LOW;
unsigned long ledFlashTimer = 0;       // timer for LED in milliseconds
unsigned long ledFlashInterval = 1000; // flash interval in milliseconds

// set the maximum run time for a zone (safeguard)
unsigned long MAX_RUN_TIME_MINUTES = 30;  // Default 30 minutes
unsigned long MAX_RUN_TIME = MAX_RUN_TIME_MINUTES * 60000;

int zones[] = {zone1, zone2, zone3, zone4, zone5,
                   zone6, zone7, zone8, zone9, zone10};
int zoneCount = 10;

// REST commands
const String REST_CMD_OFF        = "off";
const String REST_CMD_STATUS     = "status";
const String REST_CMD_ZONE       = "zone";
const String REST_CMD_ZONES      = "zones";
const String REST_CMD_SETTINGS   = "settings";
const String REST_CMD_TESTREPORT = "testreport";

// Command codes
const int OBJ_CMD_ALL_OFF  = 1;
const int OBJ_CMD_STATUS   = 2;
const int OBJ_CMD_SETTINGS = 3;
const int OBJ_CMD_ZONES    = 10;
const int OBJ_CMD_ZONE     = 100;
const int OBJ_CMD_PROGRAMS = 20;
const int OBJ_CMD_PROGRAM  = 200;
const int OBJ_CMD_REPORTTEST = 900;

// Reporting constants and variables
int maxReportAttempts    = 3;
int reportAttempts       = 0;

boolean reportingEnabled       = false; // reporting disabled by default
char reportServerHostName[512];
int  reportServerHostPort      = 80;

// Command Codes (CC)
const int CC_OFF = 0;
const int CC_ON =  1;
const int CC_STATUS  = 3;

// Command Dispatch structure - for processing incoming commands
int commandDispatchLength = 5;
int commandDispatch[]     = { 0, // command object type, 0 for none
                              0, // command object id, 0 for none
                              0, // command code, 0 for none
                              0, // value 1, 0 for none
                              0  // value 2, 0 for none
                              };
const int CD_OBJ_TYPE  = 0;
const int CD_OBJ_ID    = 1;
const int CD_CMD_CODE  = 2;
const int CD_VALUE_1   = 3;
const int CD_VALUE_2   = 4;

// Command Running structure - for managing running commands
int commandRunningLength = 4;
unsigned long commandRunning[] = {0, // pin ID, 0 for none
                                  0, // run end time in miliseconds, 0 for none
                                  0, // zone ID, 0 for none
                                  0  // run start time in milliseconds, 0 for none
                                  };
const int CR_PIN_ID     = 0;
const int CR_END_TIME   = 1;
const int CR_ZONE_ID    = 2;
const int CR_START_TIME = 3;

// Command Report structure - for reporting completed runs (use CR_ constants for indexes)
int commandReportLength = 4;
unsigned long commandReport[]  = {0, // pin ID, 0 for none
                                  0, // run end time in miliseconds, 0 for none
                                  0, // zone ID, 0 for none
                                  0  // run start time in milliseconds, 0 for none
                                  };

String jsonReply;
String reportData;

void setup(){
  // Turn on serial output for debugging
  Serial.begin(9600);

  // Start Ethernet connection and server
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();

  // Set the DNS server (for resolving hosts)
  EthernetDNS.setDNSServer(dnsServerIp);

  //Set relay pins to output
  for (int i = 0; i < zoneCount; i++){
    pinMode(zones[i], OUTPUT);
  }

  // set the LED indicator pin for output
  pinMode(ledIndicator, OUTPUT);
}

//  url buffer size
#define BUFSIZE 255

void loop(){
  char clientLine[BUFSIZE];
  int index = 0;

  // check on timed runs, shutdown expired runs
  checkTimedRun();

  // check for pending reports to be sent
  checkAndPostReport();

  // listen for incoming clients
  client = server.available();
  if (client) {

    //  reset input buffer
    index = 0;

    while (client.connected()) {
      if (client.available()) {
        char c = client.read();

        //  fill buffer with url
        if(c != '\n' && c != '\r'){

          //  if we run out of buffer, overwrite the end
          if(index >= BUFSIZE) {
            break;
            //index = BUFSIZE -1;
          }

          clientLine[index] = c;
          index++;

//          Serial.print("client-c: ");
//          Serial.println(c);
          continue;
        }
        Serial.print("http request: ");
        Serial.println(clientLine);

        //  convert clientLine into a proper
        //  string for further processing
        String urlString = String(clientLine);

        if (urlString.lastIndexOf("TTP/1.1") < 0 ){
          Serial.println("no HTTP/1.1, ignoring request");
          // not a url request, ignore this
          goto finish_http;
        }

        //  extract the operation (GET or POST)
        String op = urlString.substring(0,urlString.indexOf(' '));

        //  we're only interested in the first part...
        urlString = urlString.substring(
		urlString.indexOf('/'),
		urlString.indexOf(' ', urlString.indexOf('/')));

        //  put what's left of the URL back in client line
        urlString.toCharArray(clientLine, BUFSIZE);

        //  get the parameters
        char *arg1 = strtok(clientLine,"/");
        Serial.print("arg1: ");
        Serial.println(arg1);
        char *arg2 = strtok(NULL,"/");
        Serial.print("arg2: ");
        Serial.println(arg2);
        char *arg3 = strtok(NULL,"/");
        Serial.print("arg3: ");
        Serial.println(arg3);
        char *arg4 = strtok(NULL,"/");
        Serial.print("arg4: ");
        Serial.println(arg4);

        if (arg1 == NULL){
	  // we got no parameters. show default page
	  httpHomePage();

	} else {
          // start a json reply
          jsonReply = String();
          // identify the command
          findCmdObject(arg1);

          switch (commandDispatch[CD_OBJ_TYPE]) {

            case OBJ_CMD_ALL_OFF:   // all off command
              cmdZonesOff();
              break;

            case OBJ_CMD_STATUS: // Global status ping
              cmdGlobalStatusRequest();
              break;
              
            case OBJ_CMD_SETTINGS: // Controller settings
              findSettingsCommand(arg1);
              break;

            case OBJ_CMD_ZONE:      // zone command

              findZoneCommand(arg2);

              switch (commandDispatch[CD_CMD_CODE]){
                 case CC_OFF:
                   endTimedRun();
                   break;
                 case CC_ON:
                   findZoneTimeValue(arg3);
                   cmdZoneTimedRun();
                   break;
                 case CC_STATUS:
                   cmdZoneStatus();
                   break;
              }

              break;
            case OBJ_CMD_ZONES:     // all zones
              break;
            case OBJ_CMD_PROGRAM:   // program command
              break;
            case OBJ_CMD_PROGRAMS:  // all programs
              break;

            case OBJ_CMD_REPORTTEST:
              urlString.toCharArray(clientLine, BUFSIZE);
              testReport(clientLine);
              break;

            default:
              httpJsonReply("\"ERROR\":\"Command not recognized.\"");
          }
	}
      }
    }

    // finish http response
    finish_http:

    // clear Command Dispatch
    Serial.println("clearCommandDispatch()");
    clearCommandDispatch();

    // Clear the clientLine char array
    Serial.println("clear client line: clearCharArray()");
    clearCharArray(clientLine, BUFSIZE);

    // give the web browser time to receive the data
    delay(20);

    // close the connection:
    client.stop();

  }
} /// ========= end loop() =========

void findCmdObject(char *cmdObj){

    String commandObject = String(cmdObj);
    commandObject = commandObject.toLowerCase();

    // check for "OFF" shortcut
    if (commandObject.compareTo("off") == 0) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_ALL_OFF;
        jsonReply += "\"command\":\"zones off\"";
        return;
    }

    // check for global "status" request "/status"
    if (commandObject.compareTo(REST_CMD_STATUS) == 0) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_STATUS;
        return;
    }
    
    // check for settings request "/settings"
    if (commandObject.startsWith(REST_CMD_SETTINGS + "?")) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_SETTINGS;
        return;
    }

    // check for report test request "/testreport"
    if (commandObject.compareTo(REST_CMD_TESTREPORT) == 0) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_REPORTTEST;
        return;
    }

    // must check for plural form first
    if (commandObject.compareTo(REST_CMD_ZONES) == 0) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_ZONES;
        jsonReply += "\"zones\":";
        return;
    }

    if (commandObject.startsWith(REST_CMD_ZONE)) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_ZONE; // command object type, 0 for none
        jsonReply += "\"zone";

        // get zone number
        String zoneNumber = commandObject.substring(
		commandObject.lastIndexOf('e') + 1,
		commandObject.length() );

        commandDispatch[CD_OBJ_ID] = stringToInt(zoneNumber); // command object id, 0 for none
        jsonReply += zoneNumber;
        jsonReply += "\":";
        return;
    }

    // must check for plural form first
    if (commandObject.compareTo("programs") == 0) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_PROGRAMS;
        jsonReply += "\"programs\":";
        return;
    }
    if (commandObject.startsWith("program")) {
        commandDispatch[CD_OBJ_TYPE] = OBJ_CMD_PROGRAM;
        jsonReply += "\"program";

        // get program number
        String progNumber = commandObject.substring(
		commandObject.lastIndexOf('m') + 1,
		commandObject.length() );

        commandDispatch[CD_OBJ_ID] = stringToInt(progNumber); // command object id, 0 for none
        jsonReply += progNumber;
        jsonReply += "\":";
        return;
    }

}

// interprets the command following the /zoneX/ command prefix
void findZoneCommand(char *zoneCmd){

    String zoneCommand = String(zoneCmd);

    // if zone command is empty, treat as a status request
    if (zoneCommand.length() < 1){
        commandDispatch[CD_CMD_CODE] = CC_STATUS;
        // clear the json reply
        jsonReply = "";
        return;
    }

    zoneCommand = zoneCommand.toLowerCase();
    
    // check for "ON"
    if (zoneCommand.compareTo("on") == 0) {
        commandDispatch[CD_CMD_CODE] = CC_ON;
        jsonReply += "\"on\"";
        return;
    }

    // check for "OFF"
    if (zoneCommand.compareTo("off") == 0) {
        commandDispatch[CD_CMD_CODE] = CC_OFF;
        jsonReply += "\"off\"";
        return;
    }
    
    // check for "status"
    if (zoneCommand.compareTo(REST_CMD_STATUS) == 0) {
        commandDispatch[CD_CMD_CODE] = CC_STATUS;
        // clear the json reply
        jsonReply = "";
        return;
    }
    
}

void findZoneTimeValue(char *zoneTime){
    int time = atoi(zoneTime);
    commandDispatch[CD_VALUE_1] = time;
}

// interpret and execute settings commands 
void findSettingsCommand(char *settings){

    char *arg, *i;    
    int count=1;
    //  get the parameters
    arg = strtok_r(settings,"?",&i);
    Serial.print("arg ");
    Serial.print(count);
    Serial.print(": ");
    Serial.println(arg);

    while (arg != NULL && count < 16){
        count++;
        arg = strtok_r(NULL,"&",&i);
        if (arg != NULL) {
            Serial.print("arg ");
            Serial.print(count);
            Serial.print(": ");
            Serial.println(arg);
            setSettings(arg);
        }
    }
    // send reply, send error message if message empty
    if (jsonReply == NULL || jsonReply.length() == 0){
        jsonReply = "\"settings\":\"parameters not recognized\"";
    }
    httpJsonReply(jsonReply);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

void setSettings(char *valuePair){
    char *aLabel = strtok(valuePair, "=");
    char *aValue = strtok(NULL, "=");
    
    String label = String(aLabel);
    String value = String(aValue);

    // check for "reportingEnabled" setting
    if (label.compareTo("reportingEnabled") == 0 ||
        label.compareTo("re") == 0) {  // label shortcut
        if(jsonReply != NULL && jsonReply.length() > 0){
          jsonReply += ",";
        }
        if (value.compareTo("true") == 0) {
          reportingEnabled = true;
          jsonReply += "\"reportingEnabled\":\"true\"";
        }
        if (value.compareTo("false") == 0) {
          reportingEnabled = false;
          jsonReply += "\"reportingEnabled\":\"false\"";
        }
        return;
    }
    
    if (label.compareTo("reportingHostName") == 0 ||
        label.compareTo("rhn") == 0){ // label shortcut
        if(jsonReply != NULL && jsonReply.length() > 0){
          jsonReply += ",";
        }
        if (value.length() >= 4) {
          value.toCharArray(reportServerHostName, 512);
          jsonReply += "\"reportingHostName\":\"";
          jsonReply += value;
          jsonReply += "\"";
        }
        return;
    }

    if (label.compareTo("reportingHostPort") == 0 ||
        label.compareTo("rhp") == 0){ // label shortcut
        if(jsonReply != NULL && jsonReply.length() > 0){
          jsonReply += ",";
        }
        if (value.length() >= 1) {
          reportServerHostPort = stringToInt(value);
          jsonReply += "\"reportingHostPort\":\"";
          jsonReply += value;
          jsonReply += "\"";
        }
        return;
    }
}

// Utility functions

void clearCharArray(char array[], int length){
  for (int i=0; i < length; i++) {
    //if (array[i] == 0) {break; };
    array[i] = 0;
  }
}

void clearCommandDispatch(){
    for (int i = 0; i < commandDispatchLength; i++){
        commandDispatch[i] = 0;
    }
}

void clearCommandRunning(){
    for (int i = 0; i < commandRunningLength; i++){
        commandRunning[i] = 0;
    }
}

void clearCommandReport(){
    for (int i = 0; i < commandReportLength; i++){
        commandReport[i] = 0;
    }
}

// standard function for debug/logging
void writeLog(String logMsg){

  Serial.println(logMsg);

  //TODO: buffer log message for web delivery
  //TODO: write log message to SDCard (if available)

}

int stringToInt(String value){
  // remember to add 1 to the length for the terminating null
  char buffer[value.length() +1];
  value.toCharArray(buffer, value.length() +1 );
  return atoi(buffer);
}
