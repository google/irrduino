Irrduino
=========

Irrduino is an Arduino-based irrigation control system. It includes:

	IrrduinoController

		A project written in C that runs on the Arduino controller. It was
		prototyped using an Android ADK board and an Arduino Ethernet Shield.

	IrrduinoDroid

		This is an Android application that can control IrrduinoController.

	IrrduinoServer

		This is a Python, Google App Engine application that can control
		IrrduinoController and talk to IrrduinoDroid. It also provides
		reporting.

	IrrduinoServer/static/dart
	
		This is a game written in Dart called Lawnville that is a bit like
		Farmville, but it results in a real lawn being watered.

Setup
-----

To use these applications, you'll need to configure some server names. Search
for YOUR-SERVER-NAME in the code. See also IrrduinoServer/README.


Project Disclaimer
------------------

This project is not an official Google product (experimental or otherwise), 
it is just code that happens to be owned by Google.
