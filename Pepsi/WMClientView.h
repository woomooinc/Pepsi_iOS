//
//  WMClientView.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMClientView : UIView
@property (nonatomic, strong) IBOutlet UIImageView * avatarView;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingView;
- (void)configureViewWithAvatarURL:(NSString*)avatar name:(NSString*)name score:(NSInteger)score;
- (void)showWinner;
@end
