//
//  WMClient.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kWMName;
extern NSString * const kWMAvatar;

@interface WMClient : NSObject
@property(nonatomic, strong) NSString * name;
@property(nonatomic, strong) NSString * avatarPath;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, strong) UIImage * placeholder;
+ (id)currentClient;
- (void)addScore;
@end
