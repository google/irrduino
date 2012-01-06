# Copyright 2011 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This module contains helpers related to controlling Irrduino.

See irrduino/IrrduinoController/web-ctrl-api.txt for documentation about
talking to the server.

"""

import simplejson

from irrduinoserver.utils import web as webutils

SERVER_ROOT = "http://joefernandez.org"
MIN_TIME = 1
MAX_TIME = 10

# See: https://docs.google.com/a/google.com/spreadsheet/ccc?key=0AuX1PmdkirJmdGNWRlpOTDY3WjVNUkczR2pMVGtnS1E&hl=en_US#gid=0
ZONES = {
  1: {"nth": 0, "location": "Back Yard", "name": "Garden", "gallons_per_minute": 1.50},
  2: {"nth": 1, "location": "Back Yard", "name": "Lawn 1", "gallons_per_minute": 2.99},
  3: {"nth": 2, "location": "Back Yard", "name": "Lawn 2", "gallons_per_minute": 5.46},
  4: {"nth": 3, "location": "Back Yard", "name": "Lawn 3", "gallons_per_minute": 5.46},
  5: {"nth": 4, "location": "Back Yard", "name": "Patio Plants", "gallons_per_minute": 0.52},
  7: {"nth": 5, "location": "Front Yard", "name": "Left Side Lawn", "gallons_per_minute": 6.13},
  8: {"nth": 6, "location": "Front Yard", "name": "Right Side Lawn", "gallons_per_minute": 6.13}
}
COST_PER_CUBIC_FOOT = 0.0252
CUBIC_FEET_PER_GALLON = 0.134


def execute(path):
  """Do an HTTP GET to control the Arduino board."""
  assert path.startswith("/")
  http = webutils.create_http_with_timeout()
  (headers, body) = http.request(SERVER_ROOT + path)
  if headers["status"] != 200:
    raise RuntimeError("Irrduino error", headers, body)
  json = simplejson.loads(body)
  return json
