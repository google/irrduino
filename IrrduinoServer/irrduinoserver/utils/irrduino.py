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

ZONES = {
  1: {"location": "Back Yard", "name": "Garden"},
  2: {"location": "Back Yard", "name": "Lawn 1"},
  3: {"location": "Back Yard", "name": "Lawn 2"},
  4: {"location": "Back Yard", "name": "Lawn 3"},
  5: {"location": "Back Yard", "name": "Patio Plants"},
  7: {"location": "Front Yard", "name": "Left Side Lawn"},
  8: {"location": "Front Yard", "name": "Right Side Lawn"}
}


def execute(path):
  """Do an HTTP GET to control the Arduino board."""
  assert path.startswith("/")
  http = webutils.create_http_with_timeout()
  (headers, body) = http.request(SERVER_ROOT + path)
  if headers["status"] != 200:
    raise RuntimeError("Irrduino error", headers, body)
  json = simplejson.loads(body)
  return json
