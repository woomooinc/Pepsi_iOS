//
//  WMPrepareRoom.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMClient.h"

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
@end
