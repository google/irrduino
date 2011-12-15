// html output functions

void httpHeader(){
  client.println("HTTP/1.1 200 OK ");
  client.println("Content-Type: text/html ");
  client.println(); // REQUIRED: must send blank line first
}

void httpJsonReply(String msg){
  Serial.println("sending httpJsonReply()...");
  httpHeader();
  client.print("{");
  client.print(msg);
  client.println("}");
  client.stop();
}

void jsonStatusRunningZone(){
        jsonReply += "\"zone";
        jsonReply += commandRunning[CR_ZONE_ID];
        jsonReply += "\":\"ON\"";
        jsonReply += ",\"elapsed\":\"";
        jsonReply += (millis() - commandRunning[CR_START_TIME]) / 1000;
        jsonReply += "\"";
        jsonReply += ",\"remaining\":\"";
        jsonReply += (commandRunning[CR_END_TIME] - millis()) / 1000;
        jsonReply += "\"";
}

void httpHomePage(){
  Serial.println("sending httpHomePage()...");
  httpHeader();

  client.println("<html> ");
  client.println("<head> ");
  client.println("  <script type=\"text/javascript\"> ");
  client.println("    var http = false; ");
  client.println("    if(navigator.appName == \"Microsoft Internet Explorer\") { ");
  client.println("      http = new ActiveXObject(\"Microsoft.XMLHTTP\"); ");
  client.println("    } else { ");
  client.println("      http = new XMLHttpRequest(); ");
  client.println("    } ");
  client.println("    function timedRunNow(zone) { ");
  client.println("      http.abort();");
  client.println("      http.open(\"GET\",zone+\"/ON/\"+ document.getElementById('time').value, true); ");
  client.println("      http.onreadystatechange=function() { ");
  client.println("        if(http.readyState == 4) { ");
  client.println("          document.getElementById('response').innerHTML = http.responseText; ");
  client.println("        } ");
  client.println("      } ");
  client.println("      http.send(null); ");
  client.println("    } ");
  client.println("    function allZonesOff() { ");
  client.println("      http.abort();");
  client.println("      http.open(\"GET\",\"OFF\"); ");
  client.println("      http.onreadystatechange=function() { ");
  client.println("        if(http.readyState == 4) { ");
  client.println("          document.getElementById('response').innerHTML = http.responseText; ");
  client.println("        } ");
  client.println("      } ");
  client.println("      http.send(null); ");
  client.println("    } ");
  client.println("  </script> ");
  client.println("</head><body><center> ");
  client.println("<h1>Run Sprinklers</h1> ");
  client.println("<form> ");
  client.println("  <p>Minutes:  <input id=\"time\" type=\"text\" value=\"1\"> ");
  client.println("  <div id=\"response\"></div> ");
  client.println("  <input value=\"All Off\"      type=\"button\" onclick=\"allZonesOff()\" /><br> ");
  client.println("  <input value=\"Garden\"       type=\"button\" onclick=\"timedRunNow('zone1')\" /><br> ");
  client.println("  <input value=\"Zone 2\"       type=\"button\" onclick=\"timedRunNow('zone2')\" /><br> ");
  client.println("  <input value=\"Zone 3\"       type=\"button\" onclick=\"timedRunNow('zone3')\" /><br> ");
  client.println("  <input value=\"Zone 4\"       type=\"button\" onclick=\"timedRunNow('zone4')\" /><br> ");
  client.println("  <input value=\"Patio Plants\" type=\"button\" onclick=\"timedRunNow('zone5')\" /><br> ");
  client.println("  <input value=\"Zone 6\"       type=\"button\" onclick=\"timedRunNow('zone6')\" /><br> ");
  client.println("  <input value=\"Zone 7\"       type=\"button\" onclick=\"timedRunNow('zone7')\" /><br> ");
  client.println("  <input value=\"Zone 8\"       type=\"button\" onclick=\"timedRunNow('zone8')\" /><br> ");
  client.println("</form> ");
  client.println("</center></body> ");
  client.println("</html> ");
  client.stop();
}

