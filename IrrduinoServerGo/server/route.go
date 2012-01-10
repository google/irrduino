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

import (
	"http"
	"server/handler"
)

/* This contains the routing for the application. */
func init() {
	http.HandleFunc("/", handler.Irrigate)
	http.HandleFunc("/report", handler.Report)
	http.HandleFunc("/log", handler.Log)
	http.HandleFunc("/about", handler.About)
	http.HandleFunc("/lawnville", handler.LawnVille)
}
