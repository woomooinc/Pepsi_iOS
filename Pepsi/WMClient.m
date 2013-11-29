//
//  WMClient.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClient.h"

NSString * const kWMName = @"kWMName";
NSString * const kWMAvatar = @"kWMAvatar";

@implementation WMClient

+ (id)currentClient {
    static dispatch_once_t pred = 0;
    __strong static WMClient *_currentClient = nil;
    
    dispatch_once(&pred, ^{
        _currentClient = [[WMClient alloc] init];
        _currentClient.name = [[NSUserDefaults standardUserDefaults] stringForKey:kWMName];
        _currentClient.avatarPath = [[NSUserDefaults standardUserDefaults] stringForKey:kWMAvatar];
        if (!_currentClient.name) {
            _currentClient.name = [[UIDevice currentDevice] name];
        }
    });
    
    return _currentClient;
}

- (id)init {
    self = [super init];
    if (self) {
        _name = @"Guest";
        _avatarPath = @"http://en.gravatar.com/userimage/551665/ff3340ca34886da6fe8309c0d3f1ceb4.jpg";
        _score = 0;
    }
    return self;
}

@end
