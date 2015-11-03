//
//  ViewController.m
//  AirBeamConnector
//
//  Created by Akmal Hossain on 18/10/2015.
//  Copyright (c) 2015 Akmal Hossain. All rights reserved.
//

#import "AirCastingBLEController.h"

@interface AirCastingBLEController ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property BOOL bluetoothOn;
@property NSString* deviceName;

//@property NSString *sensorReading;

@end

@implementation AirCastingBLEController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //[self initializeBLE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Begin Bluetooth Scanning

//- (void)initializeBLE:(NSString *) device
- (void)initializeBLE
{
    self.bluetoothOn = NO;
    //NSLog(@"Discovered service %@", device);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)startScan
{
    if(!self.bluetoothOn)
    {
        NSLog(@"Bluetooth is off");
        return;
    }
    
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.discoveredPeripheral = peripheral;
    
    NSLog(@"Discovered %@", peripheral.name);
    [_deviceNames addObject:peripheral.name];
    
    if([peripheral.name  isEqual: @"raspberrypi"])
    {
        [central stopScan];
        [self.centralManager connectPeripheral:peripheral options:nil];
        
    }
    
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect");
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Trying to connect...");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error: %@", [error description]);
        return;
    }
    for(CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"Discovered service %@", service);
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error: %@", [error description]);
        return;
    }
    
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"Characteristics Found: %@", [characteristic description]);
        NSLog(@"Characteristics Value: %@", [characteristic value]);
        NSLog(@"Reading value for characteristic %@", characteristic);
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}


- (void)cancelPeripheralConnection:(CBPeripheral * )peripheral
{
    
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic
{
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"didDisconnectPeripheral");
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *data = characteristic.value;
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _sensorReading = [myString substringFromIndex: [myString length] - 100];
    NSLog(@"\n%@", _sensorReading);
    
    NSArray * arr = [_sensorReading componentsSeparatedByString:@" "];
    
    @try
    {
        _macAddress = arr[2];
        _temperature = arr[4];
        _humidity = arr[5];
        _particulateMatter = arr[15];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        
        if (![_sensorReading  isEqual: @"Read fail"]) {
            
            _macAddress = arr[1];
            _temperature = arr[3];
            _humidity = arr[4];
            _particulateMatter = arr[14];
        }
        
    }
    @finally {
        //NSLog(@"Char at index %d cannot be found", index);
        //NSLog(@"Max index is: %d", [arr length]-1);
        NSLog(@"Exception Occured");
    }
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"Bluetooth Off");
        self.bluetoothOn = NO;
    }
    else
    {
        NSLog(@"Bluetooth On");
        self.bluetoothOn = YES;
        [self startScan];
    }
}

@end
