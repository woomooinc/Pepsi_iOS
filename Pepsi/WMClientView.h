//
//  WMClientView.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMClientView : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView * avatarView;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingView;
- (void)configureCellWithAvatarURL:(NSString*)avatar andName:(NSString*)name;
@end
