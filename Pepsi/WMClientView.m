//
//  WMClientView.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientView.h"
#import "UIImageView+WebCache.h"
#import "WMBlueToothController.h"
#include <stdlib.h>

@interface WMClientView()
@property(nonatomic, strong) UIImage * placeholder;
@end

@implementation WMClientView

- (void)configureViewWithAvatarURL:(NSString*)avatar name:(NSString*)name score:(NSInteger)score {
    if (!name) {
        // keep waiting!
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
        self.nameLabel.text = @"Waiting...";
        self.avatarView.image = nil;
    }
    else {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        self.nameLabel.text = name;
        
        if (!self.placeholder) {
            int r = arc4random() % 4;
            switch (r) {
                case 0:
                    self.placeholder = [UIImage imageNamed:@"howard"];
                    break;
                case 1:
                    self.placeholder = [UIImage imageNamed:@"shao"];
                    break;
                case 2:
                    self.placeholder = [UIImage imageNamed:@"ray"];
                    break;
                case 3:
                    self.placeholder = [UIImage imageNamed:@"jason"];
                    break;
            }
        }
        [self.avatarView setImageWithURL:[NSURL URLWithString:avatar ]
                        placeholderImage:self.placeholder
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               }];
        // calculate image scale
        /*
        WMBlueToothController * ble = [WMBlueToothController sharedController];
        if ([ble totalScore] != 0) {
            CGFloat scale = score * [[ble clients] count] / [ble totalScore];
            self.avatarView.transform = CGAffineTransformMakeScale(scale, scale);
        }
         */
    }

    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.masksToBounds = YES;
    
    [self layoutIfNeeded];
}

- (void)showWinner {
    //
}

- (void)showLoser {
    UIImage * image = self.avatarView.image;
    self.avatarView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.avatarView.tintColor = [UIColor grayColor];
}

@end
