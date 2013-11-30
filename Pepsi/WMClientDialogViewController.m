//
//  WMClientDialogViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientDialogViewController.h"
#import "WMPrepareRoomViewController.h"
#import "MBProgressHUD.h"
#import "WMBlueToothController.h"

@interface WMClientDialogViewController () <WMBlueToothDelegate>

@end


@implementation WMClientDialogViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.invitorView configureViewWithAvatarURL:self.invitor.avatarPath name:self.invitor.name score:self.invitor.score placeholder:self.invitor.placeholder];
    // @howard client broadcast to server?
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    ble.delegate = self;
    [ble clientStartToBroadcast];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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

- (void)serverDidReply {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:@"clientDialogViewGotoPrepareRoomView" sender:self];
}


@end
