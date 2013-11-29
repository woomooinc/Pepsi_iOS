//
//  WMPrepareRoomViewController.h
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMPrepareRoomViewController : UICollectionViewController
@property(nonatomic, assign) NSInteger peopleCount;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * startButton;
- (IBAction)onStartButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;

@end
