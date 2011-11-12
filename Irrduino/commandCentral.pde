// functions for controlling Arduino pin outputs

void cmdZonesOff(){
    httpJsonReply("\"zones\":\"ALL OFF\"");
    shutDownAll();
}

void cmdZoneTimedRun(){

    if ( commandDispatch[OBJ_ID] == 0 || commandDispatch[VALUE_1] == 0 ){
      
        String error = "ERROR: cmdZoneTimedRun, commandDispatch not properly initialized.";
        Serial.println(error);
        httpJsonReply(error);
        return;
    }
    
    // check value is reasonable
    if (commandDispatch[VALUE_1] > MAX_RUN_TIME_MINUTES){
        commandDispatch[VALUE_1] = MAX_RUN_TIME_MINUTES;
    }

    jsonReply += ",\"time\":\"";
    jsonReply += commandDispatch[VALUE_1];
    jsonReply += "\"";

    httpJsonReply(jsonReply);

    startTimedRun(commandDispatch[OBJ_ID], commandDispatch[VALUE_1]);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

void cmdStatusRequest(){
  
    // check for running command
    if (commandRunning[CMD_OBJ] > 0){
        jsonReply += "\"pin";
        jsonReply += commandRunning[CMD_OBJ];
        jsonReply += "\":\"running\"";
    } else {
        jsonReply += "\"system status\":\"ready\"";
    }

    httpJsonReply(jsonReply);

    // clear the command, so we don't re-execute
    clearCommandDispatch();
}

void startTimedRun(int zone, unsigned long minutes){
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
    
    // set end time
    commandRunning[0] = pin; //BUG?: int to unsigned long?
    commandRunning[1] = millis() + (minutes * 60000);
}
/*
  Check on timedRuns, stop runs on expiration time
*/
void checkTimedRun(){
    // check for running command
    if (commandRunning[CMD_OBJ] > 0){
       // a command is running, check for time end
       if (millis() >= commandRunning[OBJ_ID]){
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
    Serial.println(commandRunning[CMD_OBJ]);

    reportData = "Zone: 1\nRuntime: 60";
    
    // turn off the pin for the active zone
    digitalWrite(commandRunning[CMD_OBJ], LOW);
    
    // turn off the LED indicator
    digitalWrite(ledIndicator, LOW);    // set the LED off
    ledState = LOW;                     // reset the state
    ledFlashTimer = 0;                  // reset the timer
    
    // reset commandRunning to defaults
    commandRunning[CMD_OBJ] = 0; // reset zone
    commandRunning[OBJ_ID] = 0; // reset endTime

}

boolean exceedsMaxRunTime(){
    if (commandRunning[OBJ_ID] < (millis() + MAX_RUN_TIME)){
        return false;
    }
    return true; 
}

// shutdown all zones
void shutDownAll(){

  // check if run is in progress first
  if (commandRunning[0] != 0){
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
