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


Installation of software packages
=================================

The following steps are required to install the pakcages

  - Install BlueZ protocol stack with developers package

	sudo apt-get install bluetooth bluez-utils libbluetooth-dev libudev-dev

  - Add external repository

	curl -sLS https://apt.adafruit.com/add | sudo bash

  - Install nodejs

	sudo apt-get install node
	node -v

  - Install nodejs package manager

	sudo apt-get install npm
	npm -v

  - Install Bleno package

	npm install bleno

  - Install serial port module

	npm install serialport

To install the arduino supporting package, use the following command

	sudo apt-get install arduino


Configuration
=============

After installing the required packages, airbeam sensor data can be read using the instruction below:

  - Go to Bleno folder



Troubleshooting
===============

The script have 
 * FAQ
 * Maintainers
 
Resources
=========

Online video for Bleno installation and test
https://www.youtube.com/watch?v=8YA6KVBs1pA
