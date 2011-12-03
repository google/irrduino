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

"""Handle reporting."""

from google.appengine.ext import webapp

from irrduinoserver import model
from irrduinoserver.utils import web as webutils
from irrduinoserver.utils import irrduino as irrduinoutils


class ReportsHandler(webapp.RequestHandler):
  def get(self):
    """Give the user information about the zone runs.

    This also supports ?format=JSON.

    """
    template_params = {}
    num_zone_runs_to_show = irrduinoutils.NUM_ZONES * 2
    template_params["zone_runs"] = list(model.ZoneRun.gql(
      "ORDER BY created_at DESC LIMIT %s" % num_zone_runs_to_show))
    if webutils.is_format_json(self):
      template_params["zone_runs"] = map(
        webutils.entity_to_dict, template_params["zone_runs"])
      webutils.render_json_to_response(self, template_params)
    else:
      webutils.render_to_response(self, "reports.html", template_params)

  def post(self):
    """Accept data from Irrduino.

    Store it in the datastore and just respond "OK".

    """
    try:
      zone = int(self.request.get("zone"))
      if (zone < irrduinoutils.MIN_ZONE or
          zone > irrduinoutils.MAX_ZONE):
        raise ValueError("zone out of range: %s" % zone)
      runtime = int(self.request.get("runtime"))
      if runtime <= 0:
        raise ValueError("runtime out of range: %s" % runtime)
    except (ValueError, TypeError), e:
      webutils.error_response(msg="Invalid request: %r" % e)
    else:
      zone_run = model.ZoneRun(zone=zone, runtime_seconds=runtime)
      zone_run.put()
      self.response.out.write("OK")