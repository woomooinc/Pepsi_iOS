//
//  WMClientViewCell.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMClientView.h"
#import "WMClient.h"

@interface WMClientViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView * avatarView;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UILabel * scoreLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingView;

//@property (nonatomic, strong) IBOutlet WMClientView * view;
- (void)configureCellWithClient:(WMClient*)client;
- (void)showWinner;
- (void)showLoser;
@end
