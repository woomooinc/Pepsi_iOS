//
//  WMPlayViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/30.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPlayViewController.h"
#import "WMBlueToothController.h"
#import <AudioToolbox/AudioServices.h>

@interface WMPlayViewController () <WMBlueToothDelegate, UIAccelerometerDelegate>

@property (nonatomic) SystemSoundID shakeSound;
@property (nonatomic, assign) BOOL isUp;
@property (nonatomic, assign) BOOL isDown;
@end

@implementation WMPlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    ble.delegate = self;
    
    // Setup the music of leave play mode
    NSString *soundPath = [[[NSBundle mainBundle] pathForResource:@"mb_coin" ofType:@"m4a"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *soundURL = [NSURL URLWithString:soundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_shakeSound);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.remindingLabel.hidden = YES;
                         self.scoreLabel.hidden = NO;
    } completion:^(BOOL finished) {
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WMBlueToothController sharedController] setDelegate:nil];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

// when broadcast finish, return an ordered array of client
- (void)gameDidFinish {
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    if ([WMClient currentClient] == [[ble clients] objectAtIndex:0]) {
        // make sound
    }
}

- (void)didRefresh:(NSArray *)clientArray {
    WMClient * client = [WMClient currentClient];
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", (long)[client score]];
}

#pragma mark - UIAccelerometerDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
    //NSLog(@"x:%f\ny:%f\nz:%f\n\n", acceleration.x, acceleration.y, acceleration.z);
    
    BOOL gotScore = NO;
    if (acceleration.y >= 0.5f) {
        self.isUp = YES;
        if (self.isDown) {
            gotScore = YES;
        }
        self.isDown = NO;
    }
    
    if (acceleration.y <= -0.5f) {
        self.isDown = YES;
        if (self.isUp) {
            gotScore = YES;
        }
        self.isUp = NO;
    }
    
    if (gotScore) {
        [[WMClient currentClient] addScore];
        AudioServicesPlaySystemSound(self.shakeSound);
    }
    
}


@end
