// functions for controlling Arduino pin outputs

void cmdZonesOff(){
    httpJsonReply("\"zones\":\"ALL OFF\"");
    shutDownAll();
}

void cmdZoneTimedRun(){

    if ( commandDispatch[CD_OBJ_ID] == 0 || commandDispatch[CD_VALUE_1] == 0 ){

        String error = "ERROR: cmdZoneTimedRun(), commandDispatch not properly initialized.";
        Serial.println(error);
        httpJsonReply(error);
        return;
    }

    // check value is reasonable
    if (commandDispatch[CD_VALUE_1] > MAX_RUN_TIME_MINUTES * 60){
        Serial.print("Requested time exceeds max runtime, reseting runtime to: ");
        Serial.print(MAX_RUN_TIME_MINUTES);
        Serial.println(" minutes");
        commandDispatch[CD_VALUE_1] = MAX_RUN_TIME_MINUTES * 60;
    }

    jsonReply += ",\"time\":\"";
    jsonReply += commandDispatch[CD_VALUE_1];
    jsonReply += "\"";

    httpJsonReply(jsonReply);

    startTimedRun(commandDispatch[CD_OBJ_ID], commandDispatch[CD_VALUE_1]);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

void cmdGlobalStatusRequest(){

    // check for running command
    if (commandRunning[CR_PIN_ID] > 0){
        jsonStatusRunningZone();
    } else {
        jsonReply += "\"system status\":\"ready\"";
    }

    httpJsonReply(jsonReply);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

// zone status request, should return:
// zoneX:OFF 
// - or -
// zoneX:ON, elapsed:nnnn, remaining:nnn
void cmdZoneStatus(){
    
    if (commandDispatch[CD_OBJ_ID] == commandRunning[CR_ZONE_ID]){
        jsonStatusRunningZone();
    } else {
        // zone is not active
        jsonReply += "\"zone";
        jsonReply += commandDispatch[CD_OBJ_ID];
        jsonReply += "\":\"OFF\"";

    }
    // send the response
    httpJsonReply(jsonReply);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

void startTimedRun(int zone, unsigned long seconds){
    // deactivate last zone before starting another
    endTimedRun();

    // select pin (shift object id to base zero):
    int pin = zones[zone - 1];
    Serial.print("requesting run for zone#: ");
    Serial.println(zone);
    Serial.print("starting run on pin:");
    Serial.println(pin);

    // turn on selected zone
    digitalWrite(pin, HIGH);

    // turn on the LED indicator light
    digitalWrite(ledIndicator, HIGH);  // set the LED on
    ledFlashTimer = millis() + 3000;   // set the timer
    ledState = HIGH;                   // set the state

    // set commandRunning parameters
    commandRunning[CR_ZONE_ID]    = zone;
    commandRunning[CR_PIN_ID]     = pin; //BUG?: int to unsigned long?
    commandRunning[CR_START_TIME] = millis();
    commandRunning[CR_END_TIME]   = commandRunning[CR_START_TIME] + (seconds * 1000);
}
/*
  Check on timedRuns, stop runs on expiration time
*/
void checkTimedRun(){
    // check for running command
    if (commandRunning[CR_END_TIME] > 0){
       // a command is running, check for time end
       if (millis() >= commandRunning[CR_END_TIME]){
         // close valve: stop zone X
         endTimedRun();
       } else {
         // Flash the LED
         if (millis() >= ledFlashTimer){
             if (ledState == LOW){
               ledState = HIGH;
             } else {
               ledState = LOW;
             }
             // Change the LED state
             digitalWrite(ledIndicator, ledState);

             // reset the timer for the next state change
             ledFlashTimer = millis() + ledFlashInterval;
         }
       }
    }
}

void endTimedRun(){
    Serial.print("deactivating zone: ");
    Serial.println(commandRunning[CR_PIN_ID]);

    // turn off the pin for the active zone
    digitalWrite(commandRunning[CR_PIN_ID], LOW);
    
    // record the actual end time for reporting
    commandRunning[CR_END_TIME]   = millis();
    
    // turn off the LED indicator
    digitalWrite(ledIndicator, LOW);    // set the LED off
    ledState = LOW;                     // reset the state
    ledFlashTimer = 0;                  // reset the timer

    if (reportingEnabled){
        // Capture command run data for a report
        // all report data is in the commandRunning array.
        clearCommandReport();
        
        // transfer the commandRunning data into commandReport
        for (int i = 0; i < commandReportLength; i++){
            commandReport[i] = commandRunning[i];
        }
        // that's all: report will be sent on next loop run
    }

    // clear the commandRunning array
    clearCommandRunning();

}

boolean exceedsMaxRunTime(){
    if (commandRunning[CD_OBJ_ID] < (millis() + MAX_RUN_TIME)){
        return false;
    }
    return true;
}

// shutdown all zones
void shutDownAll(){

  // check if run is in progress first
  if (commandRunning[CR_PIN_ID] != 0){
    // shut down the currently running zone
    endTimedRun();
  }

  // cycle through all pins/zones
  // for good measure
  for (int i = 0; i < zoneCount; i++){
     Serial.print("Writing pin ");
     Serial.print(zones[i]);
     Serial.println(" LOW");

     digitalWrite(zones[i], LOW);
  }
}
