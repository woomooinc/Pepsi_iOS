//
//  WMResultViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/30.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMResultViewController.h"
#import "UIImageView+WebCache.h"
#import "WMBlueToothController.h"

@interface WMResultViewController ()

@end

@implementation WMResultViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    WMClient * winner = [ble winner];
    [self.avatar setImageWithURL:[NSURL URLWithString:winner.avatarPath ]
                placeholderImage:winner.placeholder
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                       }];
    self.name.text = winner.name;
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    self.avatar.layer.masksToBounds = YES;
}


@end
