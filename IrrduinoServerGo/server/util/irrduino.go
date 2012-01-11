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

import (
	"appengine"
	"appengine/urlfetch"
	"fmt"
	"http"
	"io/ioutil"
	"os"
	"strings"
)

const SERVER_ROOT = "http://joefernandez.org"
const COST_PER_CUBIC_FOOT = 0.0252
const CUBIC_FEET_PER_GALLON = 0.134

type Zone struct {
	Nth uint;
	Location string;
	Name string;
	GPM float32;	// Gallons per minute
	Coords string;	// Coordinates for use with an image map
	CenterX uint;	// The center of the zone
	CenterY uint;
}

// See: https://docs.google.com/a/google.com/spreadsheet/ccc?key=0AuX1PmdkirJmdGNWRlpOTDY3WjVNUkczR2pMVGtnS1E&hl=en_US#gid=0
var Zones = map[int]Zone{
	1:Zone{
		Nth:0, Location:"Back Yard", Name:"Garden", GPM:1.50,
		Coords:"602,198,782,267,781,282,735,301,556,226,557,212",
		CenterX:670, CenterY:244},
	2:Zone{
		Nth:1, Location:"Back Yard", Name:"Lawn 1", GPM:2.99,
		Coords:"497,210,793,329,726,363,428,238,472,222",
		CenterX:615, CenterY:279},
	3:Zone{
		Nth:2, Location:"Back Yard", Name:"Lawn 2", GPM:5.46,
		Coords:"421,242,721,364,647,398,349,271",
		CenterX:531, CenterY:311},
	4:Zone{
		Nth:3, Location:"Back Yard", Name:"Lawn 3", GPM:5.46,
		Coords:"574,426,536,409,535,383,474,382,313,318,313,284,345,269,641,397",
		CenterX:463, CenterY:343},
	5:Zone{
		Nth:4, Location:"Back Yard", Name:"Patio Plants", GPM:0.52,
		Coords:"535,429,528,447,487,468,449,446,447,394,477,390,528,411",
		CenterX:515, CenterY:451},
	7:Zone{
		Nth:5, Location:"Front Yard", Name:"Left Side Lawn", GPM:6.13,
		Coords:"148,354,294,410,148,475,2,413",
		CenterX:151, CenterY:404},
	8:Zone{
		Nth:6, Location:"Front Yard", Name:"Right Side Lawn", GPM:6.13,
		Coords:"300,413,446,471,292,532,150,476",
		CenterX:304, CenterY:465}}

// Do an HTTP GET to control IrrduinoController.
// See (irrduino/IrrduinoController/web-ctrl-api.txt) for the API.
func ExecCmd(c appengine.Context, path string) (body string, err os.Error) {
	if !strings.HasPrefix(path, "/") {
		err = os.NewError(fmt.Sprintf("Invalid path: %v", path))
		return "", err
	}
	client := urlfetch.Client(c)
	var resp *http.Response
	if resp, err = client.Get(SERVER_ROOT + path); err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.Status != "200 OK" {
		err = os.NewError(fmt.Sprintf("Unexpected response status: %v", resp.Status))
		return "", err
	}
	var bytes []uint8
	if bytes, err = ioutil.ReadAll(resp.Body); err != nil {
		return "", err
	}
	return string(bytes), nil
}
