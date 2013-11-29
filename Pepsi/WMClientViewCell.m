//
//  WMClientViewCell.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientViewCell.h"

@implementation WMClientViewCell

- (void)configureCellWithAvatarURL:(NSString*)avatar name:(NSString*)name score:(NSInteger)score {
    [self.view configureViewWithAvatarURL:avatar name:name score:score];
}

- (void)showWinner {
    [self.view showWinner];
}

- (void)showLoser {
    [self.view showLoser];
}
@end
