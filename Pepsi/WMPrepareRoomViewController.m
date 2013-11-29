//
//  WMPrepareRoomViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPrepareRoomViewController.h"
#import "WMBlueToothController.h"
#import "WMClientViewCell.h"
#import <AudioToolbox/AudioServices.h>

@interface WMPrepareRoomViewController () <WMBlueToothDelegate, UIAccelerometerDelegate>
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic) SystemSoundID shakeSound;
@property (nonatomic, assign) BOOL isUp;
@property (nonatomic, assign) BOOL isDown;
@end

@implementation WMPrepareRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    accel.delegate = self;
    accel.updateInterval = 0.3f;
    
    self.isPlaying = NO;
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    ble.delegate = self;
    
    // Setup the music of leave play mode
    NSString *soundPath = [[[NSBundle mainBundle] pathForResource:@"mb_coin" ofType:@"m4a"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *soundURL = [NSURL URLWithString:soundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_shakeSound);
    
    if (self.isHost) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.startButton.enabled = YES;
        ble.minimumPeopleCount = self.peopleCount;
        [ble startBroadcast];
        [ble joinWithClient:[WMClient currentClient]];
    } else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.startButton.enabled = NO;
        self.peopleCount = [ble minimumPeopleCount];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark - UIAccelerometerDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
    if (!self.isPlaying) return;
    
    NSLog(@"x:%f\ny:%f\nz:%f\n\n", acceleration.x, acceleration.y, acceleration.z);
    
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

#pragma WMPrepareRoomDelegate
- (void)clientDidJoin:(WMClient*)client {
    // reload collection view
}

// when broadcast finish, return an ordered array of client
- (void)gameDidFinish {
    self.isPlaying = NO;
    self.startButton.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self.collectionView reloadData];
    // show winner effect
}

- (void)gameDidStart {
    self.peopleCount = [[[WMBlueToothController sharedController] clients] count];
    [self.collectionView reloadData];
    
    self.isPlaying = YES;
    self.startButton.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)didRefresh:(NSArray *)clientArray {
    [self.collectionView reloadData];
}

#pragma UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *clientViewIdentifier = @"WMClientViewCell";
    WMClientViewCell *cell = (WMClientViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:clientViewIdentifier forIndexPath:indexPath];
    WMClient * client = nil;
    NSArray * currentClients = [[WMBlueToothController sharedController] clients];
    NSString * avatar;
    NSString * name;
    NSInteger score;
    if ([currentClients count] >= indexPath.row + 1) {
        client = [currentClients objectAtIndex:indexPath.row];
        avatar = client.avatarPath;
        name = client.name;
        score = client.score;
    }

    [cell configureCellWithAvatarURL:avatar name:name score:score];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.peopleCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma IBAction
- (IBAction)onStartButton:(id)sender {
    [[WMBlueToothController sharedController] startGame];
}

- (IBAction)onCancelButton:(id)sender {
//    [[WMBlueToothController sharedController] cancel];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
