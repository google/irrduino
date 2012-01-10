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
//"""This is like FarmVille, but it actually works."""
//
//from google.appengine.ext import webapp
//
//from irrduinoserver.utils import web as webutils
//from irrduinoserver.utils import irrduino as irrduinoutils
//
//
//class LawnVilleHandler(webapp.RequestHandler):
//  def get(self):
//    template_params = {}
//    template_params["zones"] = sorted(irrduinoutils.ZONES.items())
//    webutils.render_to_response(self, "lawnville.html", template_params)
