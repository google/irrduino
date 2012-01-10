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

"""This module contains stuff related to the datastore."""

from google.appengine.ext import db


class ZoneRun(db.Model):
  """A zone run is when you water a zone for some amount of time."""
  zone = db.IntegerProperty()
  runtime_seconds = db.IntegerProperty()
  created_at = db.DateTimeProperty(auto_now_add=True)


def get_recent_zone_runs(num_zone_runs_to_show=100):
  return list(ZoneRun.gql(
    "ORDER BY created_at DESC LIMIT %s" % num_zone_runs_to_show))