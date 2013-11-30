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

@interface WMBlueToothController()<CBPeripheralManagerDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) BOOL isRanging;
@property (strong, nonatomic) NSData *messageToSend;
@property (strong, nonatomic) NSMutableData *messageToReceive;
@property (strong, nonatomic) CBMutableCharacteristic *sendMessageCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *receiveMessageCharacteristic;
@property (nonatomic, readwrite) NSInteger sendMessageIndex;
@property (nonatomic, strong) NSMutableDictionary *peripherals;
@property (nonatomic, assign) BOOL isServer;
@property (nonatomic, assign) BOOL isEOM;
@property (nonatomic, readwrite) NSInteger lastAmountMessageToSend;


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
    if (peripheral.state != CBPeripheralStateConnected) {
        
        BOOL hasPeripheral = NO;
        
        for (NSDictionary *peripheralObject in [self.peripherals allValues]) {
            CBPeripheral *existPeripheral = [peripheralObject objectForKey:@"pKey"];
            
            if ([existPeripheral.identifier isEqual:peripheral.identifier]) {
                [self.peripherals removeObjectForKey:advertisementData];
                hasPeripheral = YES;
                break;
            }
        }
        
        [self.peripherals setObject:@{@"pKey":peripheral} forKey:advertisementData];
        if (!hasPeripheral) {
            [central connectPeripheral:peripheral options:nil];
        }

    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSMutableArray *peripheralsArray = [[NSMutableArray alloc] init];

    for (NSDictionary *peripheralObject in [self.peripherals allValues]) {
        if (![peripheralsArray containsObject:[peripheralObject objectForKey:@"pKey"]]) {
            [peripheralsArray addObject:[peripheralObject objectForKey:@"pKey"]];
        }
    }
    
    for (CBPeripheral *connectedPeripheral in peripheralsArray) {
        if ([peripheral.identifier isEqual:connectedPeripheral.identifier]) {
            WMClient *client = [[WMClient alloc] init];
            
            NSArray *keys = [self.peripherals allKeysForObject:@{@"pKey":peripheral}];
            client.name = [[keys objectAtIndex:0]objectForKey:CBAdvertisementDataLocalNameKey];
            client.peripheral = peripheral;
            client.peripheral.delegate = self;
            [client.peripheral discoverServices:@[kAppServiceUUID]];
            [self.clients addObject:client];
            [self.delegate clientDidJoin:client];
            break;
        }
    }
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
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.centralManager.delegate = self;
        self.peripherals = [[NSMutableDictionary alloc] init];
        self.messageToReceive = [[NSMutableData alloc] init];
        self.messageToSend = [[NSData alloc] init];
    }
    return self;
}

- (void)startBroadcast {
    [self.clients removeAllObjects];
    [self.peripherals removeAllObjects];
    
    if(self.peripheralManager.state < CBPeripheralManagerStatePoweredOn)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled" message:@"To configure your device as a beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        
        return;
    }
    
    self.isServer = YES;
    NSUUID *uuid = kBeaconUUID;
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.zzb.beacons"];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:@(-59)];
    
    // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
    if(peripheralData)
    {
        if (self.isRanging) {
            [self stopRanging];
        }
        
        [self.peripheralManager startAdvertising:peripheralData];
//        [[GPUtility shareObj] initCentralManagerWithDelegate:self];
        [self.centralManager scanForPeripheralsWithServices:@[kAppServiceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
}


- (void)startGame {
    self.currentTime = 0;
    [self sendMessage:@"start"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidStart)]) {
        [self.delegate gameDidStart];
    }
    
    [self performSelector:@selector(startToRefreshTimer) withObject:nil afterDelay:5.0f];

}

- (void)startToRefreshTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refresh)  userInfo:nil repeats:YES];
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
    NSInteger countdown = self.gameDuration - self.currentTime;
    NSString * speechString = [NSString stringWithFormat:@"%li", (long)countdown];
    BOOL timesup = (self.currentTime > self.gameDuration)?YES:NO;
    
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
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRefresh)]) {
            [self.delegate didRefresh];
        }
        
        if (self.isServer) {
            // Send all scores to client
            NSMutableString *scoreAndNameString = [[NSMutableString alloc] initWithString:@"score"];
            for (WMClient *client in self.clients) {
                [scoreAndNameString appendFormat:@"::%@-%ld", client.name, (long)client.score];
            }
            [self sendMessage:scoreAndNameString];
        }
        else {
            // Send only client self to server
            NSString *scoreString = [[NSString alloc] initWithFormat:@"selfscore::%@-:%d", self.currentClient.name, self.currentClient.score];
            [self sendMessage:scoreString];
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

- (void)clientWantToGetAllUsers {
    [self sendMessage:@"alluser"];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!self.isServer) {
        return;
    }
    if ([characteristic.UUID isEqual:kSendMessageCharacteristicUUID]) {
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];

        for (WMClient *client in self.clients) {
            if ([peripheral.identifier isEqual:client.peripheral.identifier]) {
                // Have we got everything we need?
                if ([stringFromData isEqualToString:@"EOM"]) {
                    
                    NSString *msg = [[NSString alloc] initWithData:client.messageToReceive encoding:NSUTF8StringEncoding];
                    if ([msg isEqualToString:@"alluser"]) {
                        NSMutableString *str = [[NSMutableString alloc] initWithString:@"user"];
                        for (WMClient *client in self.clients) {
                            [str appendFormat:@"::%@", client.name];
                        }
                        [self sendMessage:[NSString stringWithString:str]];
                    }
                    if ([msg hasPrefix:@"selfscore::"]) {
                        NSArray *a = [msg componentsSeparatedByString:@"::"];
                        NSArray *b = [[a lastObject] componentsSeparatedByString:@"-"];
                        client.score = [[b lastObject] integerValue];
                        NSLog(@"new: score %d", [[b lastObject] integerValue]);
                    }
                    
                    
                    [client.messageToReceive setLength:0];
                }
                else {
                    // Otherwise, just add the data on to what we already have
                    [client.messageToReceive appendData:characteristic.value];
                }
                
                // Log it
                NSLog(@"Received: %@", stringFromData);
            }

        
        }
    }

}

- (void)clientStartToBroadcast {
    if ([self.peripheralManager isAdvertising]) {
        [self.peripheralManager stopAdvertising];
    }
    self.sendMessageCharacteristic = [[CBMutableCharacteristic alloc]
                                      initWithType:kSendMessageCharacteristicUUID
                                      properties:CBCharacteristicPropertyNotify                                                                          value:nil                                                                    permissions:CBAttributePermissionsReadable];
    
    self.receiveMessageCharacteristic = [[CBMutableCharacteristic alloc]
                                         initWithType:kReceiveMessageMessageCharacteristicUUID
                                         properties:CBCharacteristicPropertyWrite                                                                         value:nil                                                                    permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *mService = [[CBMutableService alloc]
                                  initWithType:kAppServiceUUID
                                  primary:YES];
    
    // Add the characteristic to the service
    mService.characteristics = @[self.sendMessageCharacteristic, self.receiveMessageCharacteristic];
    
    [self.peripheralManager addService:mService];
    
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[kAppServiceUUID]
                                                , CBAdvertisementDataLocalNameKey:[[UIDevice currentDevice] name]}];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self handleSendingMessage];
}

- (void)handleSendingMessage {
    if (self.isServer) {
        
        for (WMClient *client in self.clients) {
            if (client.sendMessageCharacteristic != nil) {
                client.isEOM = NO;
                
                NSLog(@"%@", [[NSString alloc] initWithData:client.messageToSend encoding:NSUTF8StringEncoding]);
                
                // Work out how big it should be
                NSInteger amountToSend = client.messageToSend.length;
                
                // Can't be longer than 20 bytes
                if (amountToSend > WRITE_MAX) amountToSend = WRITE_MAX;
                
                // Copy out the data we want
                NSData *chunk = [NSData dataWithBytes:client.messageToSend.bytes+client.sendMessageIndex length:amountToSend];
                
                // Send it
                [client.peripheral writeValue:chunk forCharacteristic:client.sendMessageCharacteristic type:CBCharacteristicWriteWithResponse];
                
                client.lastAmountMessageToSend = WRITE_MAX;
            }
        }
    }
    else {
        // First up, check if we're meant to be sending an EOM
        static BOOL sendingEOM = NO;
        
        if (sendingEOM) {
            
            // send it
            BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.sendMessageCharacteristic onSubscribedCentrals:nil];
            
            // Did it send?
            if (didSend) {
                
                // It did, so mark it as sent
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return;
        }
        
        // We're not sending an EOM, so we're sending data
        
        // Is there any left to send?
        
        if (self.sendMessageIndex >= self.messageToSend.length) {
            
            // No data left.  Do nothing
            return;
        }
        
        // There's data left, so send until the callback fails, or we're done.
        
        BOOL didSend = YES;
        
        while (didSend) {
            
            // Make the next chunk
            
            // Work out how big it should be
            NSInteger amountToSend = self.messageToSend.length - self.sendMessageIndex;
            
            // Can't be longer than 20 bytes
            if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
            
            // Copy out the data we want
            NSData *chunk = [NSData dataWithBytes:self.messageToSend.bytes+self.sendMessageIndex length:amountToSend];
            
            // Send it
            didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.sendMessageCharacteristic onSubscribedCentrals:nil];
            
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return;
            }
            
            NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
            NSLog(@"Sent: %@", stringFromData);
            
            // It did send, so update our index
            self.sendMessageIndex += amountToSend;
            
            // Was it the last one?
            if (self.sendMessageIndex >= self.messageToSend.length) {
                
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                sendingEOM = YES;
                
                // Send it
                BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.sendMessageCharacteristic onSubscribedCentrals:nil];
                
                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = NO;
                    
                    NSLog(@"Sent: EOM");
                }
                
                return;
            }
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *request in requests) {
        if ([request.characteristic.UUID isEqual:kReceiveMessageMessageCharacteristicUUID]) {
            NSString *stringFromData = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
            
            // Have we got everything we need?
            if ([stringFromData isEqualToString:@"EOM"]) {
                
                // We have, so show the data,
                /*
                 self.chatTextView.text = [self.chatTextView.text  stringByAppendingFormat:@"\n%@", [[NSString alloc] initWithData:self.messageToReceive encoding:NSUTF8StringEncoding]];
                 */
                
                NSString *message = [[NSString alloc] initWithData:self.messageToReceive encoding:NSUTF8StringEncoding];
                
                if ([message isEqualToString:@"start"] && [self.delegate respondsToSelector:@selector(serverDidReply)]) {
                    [self.delegate serverDidReply];
                }
                
                if ([message hasPrefix:@"user::"]) {
                    [self.delegate didGetAllUser:message];
                }
                if ([message hasPrefix:@"score::"]) {
                    [self.delegate didGetAllUserScore:message];
                }
                
                [self.messageToReceive setLength:0];
            }
            else {
                // Otherwise, just add the data on to what we already have
                [self.messageToReceive appendData:request.value];
            }
            
            // Log it
            NSLog(@"Received: %@", stringFromData);
            [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        }
    }
}

- (void)sendMessage:(NSString *)message {
    if (self.isServer) {
        for (WMClient *client in self.clients) {
            if (client.messageToSend != nil) {
                client.messageToSend = nil;
            }
            if (client.sendMessageCharacteristic != nil) {

            client.messageToSend = [[NSString stringWithFormat:@"%@", message] dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"sendMsg Client:%@", client.name);
//            if (client.sendMessageCharacteristic == nil) {
//                return;
//            }
            
                client.sendMessageIndex = 0;
                client.lastAmountMessageToSend = 0;
                [self handleSendingMessage];
            }

        }
    }
    else {
        self.messageToSend = [[NSString stringWithFormat:@"%@", message] dataUsingEncoding:NSUTF8StringEncoding];
        
        
        self.sendMessageIndex = 0;
        [self handleSendingMessage];
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!self.isServer) {
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[kReceiveMessageMessageCharacteristicUUID, kSendMessageCharacteristicUUID] forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!self.isServer) {
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:kSendMessageCharacteristicUUID]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:kReceiveMessageMessageCharacteristicUUID]) {
            for (WMClient *clinet in self.clients) {
                if ([clinet.peripheral.identifier isEqual:peripheral.identifier]) {
                    clinet.sendMessageCharacteristic = characteristic;
                    break;
                }
            }
        }
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!self.isServer) {
        return;
    }
    
    if (error.code == CBATTErrorSuccess) {
        WMClient *currentClient;
        for (WMClient *clinet in self.clients) {
            if ([clinet.peripheral isEqual:peripheral]) {
                currentClient = clinet;
                break;
            }
        }
        
        if ([characteristic.UUID isEqual:kReceiveMessageMessageCharacteristicUUID]) {
            if (currentClient.isEOM == YES) {
                return;
            }
            
            currentClient.sendMessageIndex += currentClient.lastAmountMessageToSend;
            
            // We're not sending an EOM, so we're sending data
            
            // Is there any left to send?
            
            if (currentClient.isEOM == NO && currentClient.sendMessageIndex >= currentClient.messageToSend.length) {
                currentClient.isEOM = YES;
                // No data left.  Do nothing
                [currentClient.peripheral writeValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:currentClient.sendMessageCharacteristic type:CBCharacteristicWriteWithResponse];
                return;
            }
            
            NSInteger amountToSend = currentClient.messageToSend.length - currentClient.sendMessageIndex;
            
            // Can't be longer than 20 bytes
            if (amountToSend > WRITE_MAX) amountToSend = WRITE_MAX;
            
            currentClient.lastAmountMessageToSend = amountToSend;
            
            // Copy out the data we want
            NSData *chunk = [NSData dataWithBytes:currentClient.messageToSend.bytes+currentClient.sendMessageIndex length:amountToSend];
            
            // Send it
            [currentClient.peripheral writeValue:chunk forCharacteristic:currentClient.sendMessageCharacteristic type:CBCharacteristicWriteWithResponse];
            
            
            NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
            NSLog(@"Sent: %@", stringFromData);
        }
    }
}

- (WMClient*)winner {
    WMClient * winner;
    for (WMClient * client in self.clients) {
        if (!winner) {
            winner = client;
        }
        else {
            if (client.score > winner.score) {
                winner = client;
            }
        }
    }
    return winner;
}

@end
