//
//  WMClientDialogViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientDialogViewController.h"
#import "WMPrepareRoomViewController.h"

@interface WMClientDialogViewController ()

@end


@implementation WMClientDialogViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.invitorView configureViewWithAvatarURL:self.invitor.avatarPath name:self.invitor.name score:self.invitor.score placeholder:self.invitor.placeholder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"clientDialogViewGotoPrepareRoomView"]) {
        UINavigationController * nav = (UINavigationController*)segue.destinationViewController;
        UIViewController * vc = nav.topViewController;
        if ([vc isKindOfClass:[WMPrepareRoomViewController class]]) {
            WMPrepareRoomViewController * prepareRoomVC = (WMPrepareRoomViewController*)vc;
            prepareRoomVC.isHost = NO;
        }
        
    }
}

- (IBAction)onJoinButton:(id)sender {
    // @howard will do sth to invitor
    [self performSegueWithIdentifier:@"clientDialogViewGotoPrepareRoomView" sender:self];
}

@end
