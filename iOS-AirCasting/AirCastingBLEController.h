//
//  ViewController.h
//  AirBeamConnector
//
//  Created by Akmal Hossain on 18/10/2015.
//  Copyright (c) 2015 Akmal Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface AirCastingBLEController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
@property NSString *sensorReading;
@property NSString *macAddress;
@property NSString *humidity;
@property NSString *particulateMatter;
@property NSString *temperature;
@property NSMutableArray *deviceNames;
- (void)initializeBLE:(NSString *) device;


#define SERVICE_UUID        @ "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0"
#define CHARACTERISTIC_UUID @ "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5"


@end


