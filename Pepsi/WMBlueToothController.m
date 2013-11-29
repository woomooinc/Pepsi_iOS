//
//  WMPrepareRoom.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMBlueToothController.h"
#import <AVFoundation/AVFoundation.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface WMBlueToothController()<CBPeripheralManagerDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate>
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) BOOL isRanging;


@end

@implementation WMBlueToothController

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    // Service for connect with
    [central scanForPeripheralsWithServices:@[kAppServiceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
}

+ (id)sharedController {
    static dispatch_once_t pred = 0;
    __strong static WMBlueToothController *_defaultRoom = nil;
    
    dispatch_once(&pred, ^{
        _defaultRoom = [[WMBlueToothController alloc] init];
    });
    
    return _defaultRoom;
}

- (id)init {
    self = [super init];
    if (self) {
        _gameDuration = 10;
        _minimumPeopleCount = 0;
        _currentTime = 0;
        _clients = [NSMutableArray array];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self startRanging];
    }
    return self;
}

- (void)startBroadcast {
    [self.clients removeAllObjects];
    
    NSUUID *uuid = kBeaconUUID;
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zzb.beacons"];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:@(-59)];
    
    // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
    if(peripheralData)
    {
        [self.peripheralManager startAdvertising:peripheralData];
//        [[GPUtility shareObj] initCentralManagerWithDelegate:self];
    }
}


- (void)startGame {
    self.currentTime = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidStart)]) {
        [self.delegate gameDidStart];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh)  userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)joinWithClient:(WMClient*)client {
    [self.clients addObject:client];
}

- (void)sendToServerWithResult:(NSInteger)score {
}

- (NSInteger)totalScore {
    NSInteger totalScore = 0;
    for (WMClient * client in self.clients) {
        totalScore += client.score;
    }
    return totalScore;
}

- (void)refresh {
    self.currentTime++;
    NSString * speechString = [NSString stringWithFormat:@"%i", self.currentTime];
    BOOL timesup = (self.currentTime >= self.gameDuration)?YES:NO;
    
    if (timesup) {
        speechString = @"Times Up!";
    }
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speechString];
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    [syn speakUtterance:utterance];
    
    if (timesup) {
        [self.timer invalidate];
        // @howard client send data to server, server calculate and reply back the result
        // after get all required data from client:
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidFinish)]) {
            [self.delegate gameDidFinish];
        }
    }
}

-(void)startRanging {
    
    //Check if monitoring is available or not
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSUUID *uuid = kBeaconUUID;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zzb.beacons"];
    
    
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
    
    self.isRanging = YES;
}

-(void)stopRanging {
    self.isRanging = NO;
    
    NSUUID *uuid = kBeaconUUID;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zzb.beacons"];
    
    
    [_locationManager stopRangingBeaconsInRegion:region];
    [_locationManager stopMonitoringForRegion:region];
}

@end
