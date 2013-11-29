//
//  WMPrepareRoom.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPrepareRoom.h"

@interface WMPrepareRoom()
@property (nonatomic, strong) NSArray * clients;
@end

@implementation WMPrepareRoom
- (id)init {
    self = [super init];
    if (self) {
        _gameDuration = 10;
        _minimumPeopleCount = 0;
    }
    return self;
}

- (void)startBroadcast {
}


- (void)startGame {
}
@end
