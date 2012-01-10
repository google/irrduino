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
	"fmt"
	"http"
)

func Report(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<h1>Report</h1>")
}

//"""Handle reporting."""
//
//from google.appengine.ext import webapp
//
//from irrduinoserver import model
//from irrduinoserver.utils import web as webutils
//from irrduinoserver.utils import irrduino as irrduinoutils
//from irrduinoserver.utils import ui as uiutils
//
//MINS_PER_SEC = 1 / 60.0
//
//
//class ReportsHandler(webapp.RequestHandler):
//  def get(self):
//    """Give the user information about the zone runs."""
//    template_params = {}
//    template_params["tabs"] = uiutils.generate_tabs("reports")
//    zone_runs = model.get_recent_zone_runs()
//
//    # Shuffle the data into:
//    # organized_by_date[date][nth_zone] = gallons
//    organized_by_date = {}
//    for zone_run in zone_runs:
//      created_at = zone_run.created_at
//
//      # Python months are 1-based, whereas Google Chart Tools expects them to
//      # be 0-based.
//      date = (created_at.year, created_at.month - 1, created_at.day)
//
//      if not date in organized_by_date:
//        organized_by_date[date] = [0] * len(irrduinoutils.ZONES)
//      zone_data = irrduinoutils.ZONES.get(zone_run.zone)
//
//      # You can tell IrrduinoController to water a zone even if that zone
//      # isn't hooked up.  Ignore such records.
//      if zone_data is None:
//        continue
//
//      gallons = (zone_run.runtime_seconds * MINS_PER_SEC *
//                 zone_data["gallons_per_minute"])
//      organized_by_date[date][zone_data["nth"]] += gallons
//
//    # Shuffle the data into:
//    # "[[new Date(year, month, day), zone0_gallons, ...],
//    #   ...]"
//    date_gallons_per_zone_list = []
//    sorted_organized_by_date_items = sorted(organized_by_date.items())
//    for ((year, month, day), gallons_per_zone) in \
//      sorted_organized_by_date_items:
//      gallons_per_zone_str = ", ".join(map(str, gallons_per_zone))
//      date_gallons_per_zone_list.append("[new Date(%s, %s, %s), %s]" %
//        (year, month, day, gallons_per_zone_str))
//
//    # Shuffle the data into:
//    # "[[new Date(year, month, day), cost], ...]"
//    date_cost_list = []
//    for ((year, month, day), gallons_per_zone) in \
//      sorted_organized_by_date_items:
//      gallons = sum(gallons_per_zone)
//      cost = (gallons * irrduinoutils.CUBIC_FEET_PER_GALLON *
//              irrduinoutils.COST_PER_CUBIC_FOOT)
//      date_cost_list.append("[new Date(%s, %s, %s), %s]" %
//        (year, month, day, cost))
//
//    template_params["zones"] = sorted(irrduinoutils.ZONES.items())
//    template_params["water_usage_rows"] = \
//      "[%s]" % ",\n".join(date_gallons_per_zone_list)
//    template_params["water_cost_rows"] = \
//      "[%s]" % ",\n".join(date_cost_list)
//    webutils.render_to_response(self, "reports.html", template_params)
