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
from irrduinoserver.utils import ui as uiutils


class WelcomeHandler(webapp.RequestHandler):
  def get(self):
    template_params = {}
    template_params["tabs"] = uiutils.generate_tabs("controls")
    webutils.render_to_response(self, "welcome.html", template_params)

  def post(self):
    """Control the sprinklers.

    TODO: This is just some sample code.

    """
    template_params = {}
    if self.request.get("get-system-status"):
      response = irrduinoutils.execute("/status")
      assert (response.get("system status") == "ready" or
              "running" in response.values())
    elif self.request.get("water-zone-1"):
      response = irrduinoutils.execute("/zone1/on/1")
      assert response["zone1"] == "on"
      assert int(response["time"]) == 1
    elif self.request.get("turn-off-everything"):
      response = irrduinoutils.execute("/off")
      assert response["zones"] == "ALL OFF"
    else:
      raise ValueError("Invalid submit button")
    template_params["status"] = response
    webutils.render_to_response(self, "welcome.html", template_params)
