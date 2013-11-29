//
//  WMClientView.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientView.h"
#import "UIImageView+WebCache.h"

@implementation WMClientView

- (void)configureCellWithAvatarURL:(NSString*)avatar andName:(NSString*)name {
    if (!name) {
        // keep waiting!
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
        self.nameLabel.text = @"Waiting...";
    }
    else {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        
        [self.avatarView setImageWithURL:[NSURL URLWithString:avatar ]
                        placeholderImage:[UIImage imageNamed:@"howard"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               }];
        self.nameLabel.text = name;
    }
}

@end
