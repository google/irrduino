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

"""This module contains helpers related to user interface rendering"""



""" takes a parameter for a selected tab (e.g., "reports") and generates a tab list """
def generate_tabs(tab_name=None):
  if tab_name is None:
    tab_name = "welcome"
  tabs = []
  for (name, url) in (
    ("Controls", "/"),
    ("Reports", "/reports"),
    ("About", "/about")
  ):
    selected = ""
    if tab_name.lower() == name.lower():
      selected = " class=selected"
        
    tabs.append('<li%s><a href="%s">%s</a></li>' % (selected, url, name))
  
  return "".join(tabs)