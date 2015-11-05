README
======

This file contains the instructions to configure
Bleno in Raspbian for Bluetooth service.

Bluetooth Service for Raspberry Pi
----------------------------------

Synopsis
========

This listed set of scripts has been developed
in JavaScript to create a notification service
for Bluetooth in Bleno.


Requirements
============

Hardware Modules
----------------

  Raspberry Pi 2 Model B
  Bluetooth 4.0 USB Module (v2.1 Back- Compatible)
  AirBeam Sensor Device


Software Packages
-----------------

  Raspbian OS Jessie (Kernel 4.1)
  BlueZ
  nodejs
  npm
  bleno
  serialport

Supporting package
------------------

  Arduino
  
* Arduino package allow to monitor the AirBeam device through its serial monitor tool

Installation of software packages
=================================

The following steps are required to install the pakcages

  - Update the OS
  
  	sudo apt-get update

  - Install BlueZ protocol stack with developers package

	sudo apt-get install bluetooth bluez libbluetooth-dev libudev-dev

  - Add external repository

	curl -sLS https://apt.adafruit.com/add | sudo bash

  - Install nodejs

	sudo apt-get install node
	node -v

  - Install nodejs package manager

	sudo apt-get install npm
	npm -v

  - Create a directory and go inside directory
  
  	mkdir bleno
  	cd bleno

  - Install Bleno package

	npm install bleno

  - Install serial port module

	npm install serialport

To install the arduino supporting package, use the following command

	sudo apt-get install arduino


Configuration
=============

After installing the required packages, airbeam sensor data can be read using the instruction below:

  - Go to bleno folder created during installation 
  - Download all JavaScript files and the airbeamdata.txt file and save in the directory
  
Run Scripts
===========

After configuration, all scripts can be executed from that directory

  - Go to bleno directory created during installation
  
  - To check the AirBeam device connected through USB
  
  	sudo node checkAirbeam.js
  	
  - To run the Bluetooth notifying service for AirBeam data collection
  
  	sudo node airbeamNotifyService.js

After service starts, run the AirCasting application for iOS.


Troubleshooting
===============

The script have 
 * FAQ
 * Maintainers
 
Resources
=========

Raspbian OS download
https://www.raspberrypi.org/downloads/raspbian/

BlueZ programming guide
https://people.csail.mit.edu/albert/bluez-intro/

Bleno package in GitHub
https://github.com/sandeepmistry/bleno

Online video for Bleno installation and test
https://www.youtube.com/watch?v=8YA6KVBs1pA
