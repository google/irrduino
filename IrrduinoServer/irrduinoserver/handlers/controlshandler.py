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


class ControlsHandler(webapp.RequestHandler):
  def get(self, template_params=None):
    if template_params is None:
      template_params = {}
    template_params["tabs"] = uiutils.generate_tabs("controls")
    template_params["zones"] = sorted(irrduinoutils.ZONES.items())
    template_params["times"] = xrange(irrduinoutils.MIN_TIME, irrduinoutils.MAX_TIME + 1)
    webutils.render_to_response(self, "welcome.html", template_params)

  def post(self):
    """Control the sprinklers.

    Use assertions for IrrduinoController errors and ValueError exceptions for
    unexpected user input errors.

    """
    if self.request.get("get-system-status"):
      response = irrduinoutils.execute("/status")
      assert response
    elif self.request.get("water-zone"):
      zone = int(self.request.get("zone"))
      time = int(self.request.get("time"))
      if not zone in irrduinoutils.ZONES:
        raise ValueError("Invalid zone: %s" % zone)
      if not (irrduinoutils.MIN_TIME <= time <= irrduinoutils.MAX_TIME):
        raise ValueError("Invalid time: %s" % time)
      response = irrduinoutils.execute("/zone%s/on/%s" % (zone, time))
      assert response["zone%s" % zone] == "on"
      assert int(response["time"]) == time
    elif self.request.get("turn-off-everything"):
      response = irrduinoutils.execute("/off")
      assert response["zones"] == "ALL OFF"
      assert response["zones"] == "ALL OFF"
    else:
      raise ValueError("Invalid submit button")
    self.get({"status": response})
