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

"""This is the welcome page for the app."""

from google.appengine.ext import webapp

from irrduinoserver.utils import web as webutils
from irrduinoserver.utils import irrduino as irrduinoutils


class WelcomeHandler(webapp.RequestHandler):
  def get(self, template_params=None):
    if template_params is None:
      template_params = {}
    template_params["zones"] = xrange(irrduinoutils.MIN_ZONE, irrduinoutils.MAX_ZONE + 1)
    template_params["times"] = xrange(irrduinoutils.MIN_TIME, irrduinoutils.MAX_TIME + 1)
    webutils.render_to_response(self, "welcome.html", template_params)

  def post(self):
    """Control the sprinklers."""
    if self.request.get("get-system-status"):
      response = irrduinoutils.execute("/status")
      assert (response.get("system status") == "ready" or
              "running" in response.values(),
              "Unexpected system status: %r" % response)
    elif self.request.get("water-zone"):
      zone = int(self.request.get("zone"))
      time = int(self.request.get("time"))
      assert irrduinoutils.MIN_ZONE <= zone <= irrduinoutils.MAX_ZONE
      assert irrduinoutils.MIN_TIME <= time <= irrduinoutils.MAX_TIME
      response = irrduinoutils.execute("/zone%s/on/%s" % (zone, time))
      assert response["zone%s" % zone] == "on"
      assert int(response["time"]) == time
    elif self.request.get("turn-off-everything"):
      response = irrduinoutils.execute("/off")
      assert response["zones"] == "ALL OFF"
    else:
      raise ValueError("Invalid submit button")
    self.get({"status": response})
