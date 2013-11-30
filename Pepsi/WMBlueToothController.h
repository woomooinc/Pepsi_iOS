//
//  WMPrepareRoom.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMClient.h"


#define kAppServiceUUID [CBUUID UUIDWithString:@"8E407657-E119-4742-9D99-C029B08B2B93"]

#define kSendMessageCharacteristicUUID      [CBUUID UUIDWithString:@"9AAA4C67-8162-4BCD-A093-BA1C78A5222F"]
#define kReceiveMessageMessageCharacteristicUUID      [CBUUID UUIDWithString:@"04CFE68F-A1C2-4F1B-B385-A162A0CB4215"]
#define kBeaconUUID      [[NSUUID alloc] initWithUUIDString:@"A42A0CFD-B994-41F0-B39C-2BEFA38913D2"]

#define NOTIFY_MTU  20
#define WRITE_MAX   128

// @howard handle BLE related here

@protocol WMBlueToothDelegate <NSObject>
@optional
- (void)clientDidJoin:(WMClient*)client;
- (void)serverDidReply;
- (void)gameDidStart;
- (void)gameDidFinish; // an ordered array of client
- (void)didRefresh:(NSArray*)clientArray;

- (void)clientDidReject:(WMClient*)client;
- (void)clientDidLeave:(WMClient*)client;
@end

@interface WMBlueToothController : NSObject
@property (nonatomic, strong) NSMutableArray * clients;
@property (nonatomic, assign) CGFloat gameDuration;
@property (nonatomic, assign) NSInteger minimumPeopleCount; // if minimumPeopleCount != 0, startGame automatically when self.clients.count >= peopleCount
@property(nonatomic, weak) id<WMBlueToothDelegate> delegate;
+ (id)sharedController;
- (void)startBroadcast;
- (void)startGame;
- (void)joinWithClient:(WMClient*)client;
- (void)sendToServerWithResult:(NSInteger)score;
- (NSInteger)totalScore;
- (void)clientStartToBroadcast;
@end
