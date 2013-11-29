//
//  WMPrepareRoom.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMClient.h"

@protocol WMPrepareRoomDelegate <NSObject>
- (void)clientDidJoin:(WMClient*)client;

// when broadcast finish, return an ordered array of client
- (void)roomServiceDidFinishWithClients:(NSArray*)clientArray;

@optional
- (void)clientDidReject:(WMClient*)client;
- (void)clientDidLeave:(WMClient*)client;
@end

@interface WMPrepareRoom : NSObject
@property (nonatomic, assign) CGFloat gameDuration;
@property (nonatomic, assign) NSInteger minimumPeopleCount; // if minimumPeopleCount != 0, startGame automatically when self.clients.count >= peopleCount
@property(nonatomic, weak) id<WMPrepareRoomDelegate> delegate;
- (void)startBroadcast;
- (void)startGame;
@end
