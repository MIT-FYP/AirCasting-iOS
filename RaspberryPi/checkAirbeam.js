var arduinoSerialPort = '/dev/ttyACM0';	//Serial port over USB connection between the Raspberry Pi and the Arduino
console.log(arduinoSerialPort);

var serialport = require('serialport');
var serialPort = new serialport.SerialPort(arduinoSerialPort,
{//Listening on the serial port for data coming from Arduino over USB
	parser: serialport.parsers.readline('\n')
});

serialPort.on('open', function (data)
{//When a new line of text is received from Arduino over USB

serialPort.on('data', function(data) {
	
    console.log('data received: ' + data);   
	
	serialPort.close(function () {
        console.log('closing');
      });
  });
});

