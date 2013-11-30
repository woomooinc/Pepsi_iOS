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
#import <AVFoundation/AVFoundation.h>

@interface WMPrepareRoomViewController () <WMBlueToothDelegate, UIAccelerometerDelegate>
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic) SystemSoundID shakeSound;
@property (nonatomic, assign) BOOL isUp;
@property (nonatomic, assign) BOOL isDown;
@property (nonatomic, assign) BOOL hasWinner;
@end

@implementation WMPrepareRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    accel.delegate = self;
    accel.updateInterval = 0.3f;
    
    self.hasWinner = NO;
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
        [ble clientWantToGetAllUsers];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WMBlueToothController sharedController] setDelegate:nil];
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didGetAllUser:(NSString *)userString {
    NSLog(@"%@", userString);
    
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    [ble.clients removeAllObjects];
    
    NSArray *a = [userString componentsSeparatedByString:@"::"];
    for (int i=1; i<[a count]; i++) {
        WMClient *client = [[WMClient alloc] init];
        client.name = [a objectAtIndex:i];
        [ble.clients addObject:client];
    }
    self.peopleCount = [ble.clients count];
    [self.collectionView reloadData];
}

#pragma mark - UIAccelerometerDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if (!self.isPlaying) return;
    
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

#pragma WMPrepareRoomDelegate
- (void)clientDidJoin:(WMClient*)client {
    [self.collectionView reloadData];
}

// when broadcast finish, return an ordered array of client
- (void)gameDidFinish {
    self.isPlaying = NO;
    self.startButton.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.hasWinner = YES;
    [self.collectionView reloadData];
    // show winner effect!
    
    WMBlueToothController * ble = [WMBlueToothController sharedController];
    if ([WMClient currentClient] == [[ble clients] objectAtIndex:0]) {
        // make sound
    }
}

- (void)gameDidStart {
    self.hasWinner = NO;
    self.peopleCount = [[[WMBlueToothController sharedController] clients] count];
    [self.collectionView reloadData];
    
    self.isPlaying = YES;
    self.startButton.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Game start, shake your iPhone now!"];
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    [syn speakUtterance:utterance];
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
    UIImage * placeholder;
    if ([currentClients count] >= indexPath.row + 1) {
        client = [currentClients objectAtIndex:indexPath.row];
        avatar = client.avatarPath;
        name = client.name;
        score = client.score;
        placeholder = client.placeholder;
    }

    [cell configureCellWithAvatarURL:avatar name:name score:score placeholder:placeholder];
    
    if (self.hasWinner) {
        if (indexPath.row == 0) {
            [cell showWinner];
        } else {
            [cell showLoser];
        }
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.peopleCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark --
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasWinner && 0 == indexPath.row) {
        return CGSizeMake(280, 350);
    }
    else {
        return CGSizeMake(80, 100);
    }
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
