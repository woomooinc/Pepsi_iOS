//
//  WMPrepareRoom.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMBlueToothController.h"

@interface WMBlueToothController()
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger currentTime;
@end

@implementation WMBlueToothController

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
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh)  userInfo:nil repeats:YES];
    }
    return self;
}

- (void)startBroadcast {
    [self.clients removeAllObjects];
}


- (void)startGame {
    self.currentTime = 0;
    [self.timer fire];
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidStart)]) {
        [self.delegate gameDidStart];
    }
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
    if (self.currentTime >= self.gameDuration) {
        [self.timer invalidate];
        // @howard client send data to server, server calculate and reply back the result
        // after get all required data from client:
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidFinish)]) {
            [self.delegate gameDidFinish];
        }
    }
}
@end