//
//  WMClient.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * const kWMName;
extern NSString * const kWMAvatar;

@interface WMClient : NSObject
@property(nonatomic, strong) NSString * name;
@property(nonatomic, strong) NSString * avatarPath;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, strong) UIImage * placeholder;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign)BOOL isEOM;
@property (strong, nonatomic) CBCharacteristic *sendMessageCharacteristic;
@property (strong, nonatomic) NSMutableData *messageToReceive;
@property (strong, nonatomic) NSData *messageToSend;
@property (nonatomic, readwrite) NSInteger sendMessageIndex;
@property (nonatomic, readwrite) NSInteger lastAmountMessageToSend;

+ (id)currentClient;
- (void)addScore;
@end
