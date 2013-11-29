//
//  WMPrepareRoom.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPrepareRoom.h"

@interface WMPrepareRoom()
@end

@implementation WMPrepareRoom

+ (id)defaultRoom {
    static dispatch_once_t pred = 0;
    __strong static WMPrepareRoom *_defaultRoom = nil;
    
    dispatch_once(&pred, ^{
        _defaultRoom = [[WMPrepareRoom alloc] init];
    });
    
    return _defaultRoom;
}

- (id)init {
    self = [super init];
    if (self) {
        _gameDuration = 10;
        _minimumPeopleCount = 0;
        _clients = [NSMutableArray array];
    }
    return self;
}

- (void)startBroadcast {
    [self.clients removeAllObjects];
}


- (void)startGame {
}

- (void)joinWithClient:(WMClient*)client {
    [self.clients addObject:client];
}
@end
