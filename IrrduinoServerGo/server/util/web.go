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

package util

//"""This module contains helpers related to rendering, etc."""
//
//import datetime
//import os
//import pdb
//import simplejson
//import sys
//import time
//
//from google.appengine.ext import db
//from google.appengine.ext.webapp import template
//
//import httplib2
//
//HTTP_TIMEOUT = 10
//SIMPLE_TYPES = (int, long, float, bool, dict, basestring, list)
//JSON_INDENTATION = " " * 2
//
//
//def render_to_string(template_name, template_params=None):
//  """Render a template and return it as a string."""
//  if template_params is None:
//    template_params = {}
//  path = os.path.join(os.path.dirname(__file__), os.pardir, 'templates',
//                      template_name)
//  return template.render(path, template_params)
//
//
//def render_to_response(handler, template_name, template_params=None,
//                       content_type=None):
//  """Render a template and write it to handler.response.out.
//
//  Optionally, set the "Content-Type" header.
//
//  """
//  if content_type is not None:
//    handler.response.headers['Content-Type'] = content_type
//  handler.response.out.write(
//    render_to_string(template_name, template_params))
//
//
//def error_response(handler, status=400, msg="Error", content_type="text/plain"):
//  handler.response.set_status(status)
//  handler.response.headers['Content-Type'] = content_type
//  handler.response.out.write(msg)
//
//  
//def render_json_to_response(handler, obj):
//  """Serialize obj to JSON and write it out to the response stream."""
//  handler.response.headers['Content-Type'] = 'application/json'
//  handler.response.out.write(simplejson.dumps(obj, indent=JSON_INDENTATION))
//
//
//def rescue_default(callback, default=""):
//  """Call callback.  If there's an exception, return default.
//
//  It's convenient to use lambda to wrap the expression in order to
//  create a callback.  Only catch IndexError, AttributeError, and ValueError.
//
//  """
//  try:
//    return callback()
//  except (IndexError, AttributeError, ValueError):
//    return default
//
//
//def require_params(handler, params, errors=None):
//  if errors is None:
//    errors = []
//  for param in params:
//    if not handler.request.get(param):
//      errors.append("Please enter a value for %s." % param)
//  return errors
//
//
//def pdb_set_trace():
//  """This is how to use pdb with Google App Engine.
//
//  You'll need to restart the server after using this.  Sorry.
//
//  """
//  for attr in ('stdin', 'stdout', 'stderr'):
//    setattr(sys, attr, getattr(sys, '__%s__' % attr))
//  pdb.set_trace()
//
//
//def create_http_with_timeout():
//  """Call httplib2.Http and set a timeout."""
//  return httplib2.Http(timeout=HTTP_TIMEOUT)
//
//
//def is_format_json(handler):
//  """Return True if the requested format is "JSON"."""
//  return handler.request.get("format").lower() == "json"
//
//
//def entity_to_dict(entity):
//  """Convert a data entity to a dict.
//
//  Taken from: http://stackoverflow.com/questions/1531501/json-serialization-of-google-app-engine-models
//  
//  """
//
//  output = {}
//
//  for key, prop in entity.properties().iteritems():
//    value = getattr(entity, key)
//
//    if value is None or isinstance(value, SIMPLE_TYPES):
//      output[key] = value
//    elif isinstance(value, datetime.date):
//
//      # Convert date/datetime to ms-since-epoch ("new Date()").
//      ms = time.mktime(value.utctimetuple()) * 1000
//      ms += getattr(value, 'microseconds', 0) / 1000
//      output[key] = int(ms)
//
//    elif isinstance(value, db.GeoPt):
//      output[key] = {'lat': value.lat, 'lon': value.lon}
//    elif isinstance(value, db.Model):
//      output[key] = to_dict(value)
//    else:
//      raise ValueError('Cannot encode: %r' % repr(prop))
//
//  return output
