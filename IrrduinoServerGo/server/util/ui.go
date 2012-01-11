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

// This module contains helpers related to user interface rendering.
package util

import (
	"fmt"
	"strings"
)

// Generate a tab list, given the currently selected tab.
func GenerateTabs(current string) string {
	lawnville := "javascript:window.open('/lawnville', 'lawnville', 'width=800, height=600, status=no, toolbar=no, menubar=no, location=no, resizable=no, scrollbars=no')"
	tabs := []string{
		generateTab("Irrigate", "/", current),
		generateTab("Log", "/log", current),
		generateTab("Reports", "/reports", current),
		generateTab("About", "/about", current),
		generateTab("LawnVille", lawnville, current)}
	return strings.Join(tabs, "")
}

func generateTab(name string, url string, current string) string {
	selected := ""
	if strings.ToLower(name) == strings.ToLower(current) {
		selected = " class=selected"
	}
	return fmt.Sprintf("<li%v><a href=\"%v\">%v</a></li>", selected, url, name)
}
