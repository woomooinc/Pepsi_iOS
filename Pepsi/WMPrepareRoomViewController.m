//
//  WMPrepareRoomViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPrepareRoomViewController.h"
#import "WMPrepareRoom.h"

@interface WMPrepareRoomViewController ()
@property (nonatomic, strong) WMPrepareRoom * room;
@end

@implementation WMPrepareRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.room = [[WMPrepareRoom alloc] init];
    self.room.minimumPeopleCount = self.peopleCount;
    [self.room startBroadcast];
}

@end
