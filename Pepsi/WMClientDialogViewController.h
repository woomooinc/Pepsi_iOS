//
//  WMClientDialogViewController.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMClientView.h"
#import "WMClient.h"

@interface WMClientDialogViewController : UIViewController
@property (nonatomic, strong) WMClient * invitor;
@property (nonatomic, strong) IBOutlet WMClientView * invitorView;
- (IBAction)onJoinButton:(id)sender;
@end
