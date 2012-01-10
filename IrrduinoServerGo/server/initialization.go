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

package server

//"""This module contains various initialization routines.
//
//Many of these are HACKs that must be called very early in the application.
//That's also why I have to be so careful about the order of imports.
//
//"""
//
//import os
//import sys
//
//
//def fix_sys_path():
//  """Setup the correct sys.path."""
//  third_party = os.path.join(os.path.dirname(__file__), os.pardir, 'third-party')
//  if third_party not in sys.path:
//    sys.path.insert(0, third_party)
