var arduinoSerialPort = '/dev/ttyACM0';	//Serial port over USB connection between the Raspberry Pi and the Arduino
var serialport = require('serialport');
var serialPort = new serialport.SerialPort(arduinoSerialPort,
{//Listening on the serial port for data coming from Arduino over USB
	parser: serialport.parsers.readline('\n')
});

var sensorData;
var fs = require('fs');

serialPort.on('open', function (data)
{//When a new line of text is received from Arduino over USB

serialPort.on('data', function(data) {

    // write sensor data	
    sensorData = data + "\n";
    //console.log(sensorData);
    
    fs.writeFile("airbeamdata.txt", sensorData, function(err) {
		if(err) {
        return console.log(err);
		}
		//console.log("The file was saved!");
	});
    	
	serialPort.close(function () {
        //console.log('closing');
      });
  });
}); 

