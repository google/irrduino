// Copyright 2011 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package handler

import (
	"http"
	"server/tmpl"
)

// This is the welcome page for the app.
func Irrigate(w http.ResponseWriter, r *http.Request) {
	tmpl.TemplateSet.Execute(w, "irrigate", nil)
}

//from google.appengine.ext import webapp
//
//from irrduinoserver.utils import web as webutils
//from irrduinoserver.utils import irrduino as irrduinoutils
//from irrduinoserver.utils import ui as uiutils
//
//SECS_PER_MINUTE = 60
//MAX_TIME_MINS = 10
//MIN_TIME_SECS = 1
//MAX_TIME_SECS = MAX_TIME_MINS * SECS_PER_MINUTE
//
//
//class ControlsHandler(webapp.RequestHandler):
//  def get(self, template_params=None):
//    if template_params is None:
//      template_params = {}
//    template_params["tabs"] = uiutils.generate_tabs("controls")
//    template_params["zones"] = sorted(irrduinoutils.ZONES.items())
//    template_params["secs_and_mins"] = \
//      [(mins * SECS_PER_MINUTE, mins)
//       for mins in xrange(1, MAX_TIME_MINS + 1)]
//    webutils.render_to_response(self, "controls.html", template_params)
//
//  def post(self):
//    """Control the sprinklers.
//
//    Use assertions for IrrduinoController errors and ValueError exceptions for
//    unexpected user input errors.
//
//    """
//    if self.request.get("get-system-status"):
//      response = irrduinoutils.execute("/status")
//      assert response
//    elif self.request.get("water-zone"):
//      zone = int(self.request.get("zone"))
//      secs = int(self.request.get("secs"))
//      if not zone in irrduinoutils.ZONES:
//        raise ValueError("Invalid zone: %s" % zone)
//      if not (MIN_TIME_SECS <= secs <= MAX_TIME_SECS):
//        raise ValueError("Invalid secs: %s" % secs)
//      response = irrduinoutils.execute("/zone%s/on/%ss" % (zone, secs))
//      assert response["zone%s" % zone] == "on"
//      assert int(response["time"]) == secs
//    elif self.request.get("turn-off-everything"):
//      response = irrduinoutils.execute("/off")
//      assert response["zones"] == "ALL OFF"
//      assert response["zones"] == "ALL OFF"
//    else:
//      raise ValueError("Invalid submit button")
//    self.get({"status": response})
