//# Copyright 2011 Google Inc.
//#
//# Licensed under the Apache License, Version 2.0 (the "License");
//# you may not use this file except in compliance with the License.
//# You may obtain a copy of the License at
//#
//#   http://www.apache.org/licenses/LICENSE-2.0
//#
//# Unless required by applicable law or agreed to in writing, software
//# distributed under the License is distributed on an "AS IS" BASIS,
//# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//# See the License for the specific language governing permissions and
//# limitations under the License.
//
//"""This module contains helpers related to controlling Irrduino.
//
//See irrduino/IrrduinoController/web-ctrl-api.txt for documentation about
//talking to the server.
//
//"""
//
//import simplejson
//
//from irrduinoserver.utils import web as webutils
//
//SERVER_ROOT = "http://joefernandez.org"
//
//# See: https://docs.google.com/a/google.com/spreadsheet/ccc?key=0AuX1PmdkirJmdGNWRlpOTDY3WjVNUkczR2pMVGtnS1E&hl=en_US#gid=0
//ZONES = {
//  1: {"nth": 0, "location": "Back Yard", "name": "Garden",
//      "gallons_per_minute": 1.50,
//      "coordinates": "602,198,782,267,781,282,735,301,556,226,557,212",
//      "center": (670, 244)},
//  2: {"nth": 1, "location": "Back Yard", "name": "Lawn 1",
//      "gallons_per_minute": 2.99,
//      "coordinates": "497,210,793,329,726,363,428,238,472,222",
//      "center": (615, 279)},
//  3: {"nth": 2, "location": "Back Yard", "name": "Lawn 2",
//      "gallons_per_minute": 5.46,
//      "coordinates": "421,242,721,364,647,398,349,271",
//      "center": (531, 311)},
//  4: {"nth": 3, "location": "Back Yard", "name": "Lawn 3",
//      "gallons_per_minute": 5.46, "coordinates":
//      "574,426,536,409,535,383,474,382,313,318,313,284,345,269,641,397",
//      "center": (463, 343)},
//  5: {"nth": 4, "location": "Back Yard", "name": "Patio Plants",
//      "gallons_per_minute": 0.52,
//      "coordinates": "535,429,528,447,487,468,449,446,447,394,477,390,528,411",
//      "center": (515, 451)},
//  7: {"nth": 5, "location": "Front Yard", "name": "Left Side Lawn",
//      "gallons_per_minute": 6.13,
//      "coordinates": "148,354,294,410,148,475,2,413",
//      "center": (151, 404)},
//  8: {"nth": 6, "location": "Front Yard", "name": "Right Side Lawn",
//      "gallons_per_minute": 6.13,
//      "coordinates": "300,413,446,471,292,532,150,476",
//      "center": (304, 465)}
//}
//COST_PER_CUBIC_FOOT = 0.0252
//CUBIC_FEET_PER_GALLON = 0.134
//
//
//def execute(path):
//  """Do an HTTP GET to control the Arduino board."""
//  assert path.startswith("/")
//  http = webutils.create_http_with_timeout()
//  (headers, body) = http.request(SERVER_ROOT + path)
//  if headers["status"] != 200:
//    raise RuntimeError("Irrduino error", headers, body)
//  json = simplejson.loads(body)
//  return json
