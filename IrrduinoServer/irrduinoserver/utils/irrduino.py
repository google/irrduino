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

"""This module contains helpers related to controlling Irrduino."""

import simplejson

from irrduinoserver.utils import web as webutils

SERVER_ROOT = "http://joefernandez.org"
MIN_ZONE = 1
MAX_ZONE = 8
NUM_ZONES = MAX_ZONE - MIN_ZONE + 1
MIN_TIME = 1
MAX_TIME = 10


def execute(path):
  """Do an HTTP GET to control the Arduino board."""
  assert path.startswith("/")
  http = webutils.create_http_with_timeout()
  (headers, body) = http.request(SERVER_ROOT + path)
  if headers["status"] != 200:
    raise RuntimeError("Irrduino error", headers, body)
  json = simplejson.loads(body)
  return json
