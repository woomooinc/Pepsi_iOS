//
//  WMClientViewCell.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMClientView.h"

@interface WMClientViewCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet WMClientView * view;
- (void)configureCellWithAvatarURL:(NSString*)avatar name:(NSString*)name score:(NSInteger)score placeholder:(UIImage*)placeholder;
- (void)showWinner;
- (void)showLoser;
@end
