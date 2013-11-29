//
//  WMPrepareRoomViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMPrepareRoomViewController.h"
#import "WMPrepareRoom.h"
#import "WMClientView.h"

@interface WMPrepareRoomViewController () <WMPrepareRoomDelegate>
@end

@implementation WMPrepareRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isHost) {
        WMPrepareRoom * room = [WMPrepareRoom defaultRoom];
        room.minimumPeopleCount = self.peopleCount;
        room.delegate = self;
        
        [room startBroadcast];
        [room joinWithClient:[WMClient currentClient]];
    }
}

#pragma WMPrepareRoomDelegate
- (void)clientDidJoin:(WMClient*)client {
    // reload collection view
}

// when broadcast finish, return an ordered array of client
- (void)roomServiceDidFinishWithClients:(NSArray*)clientArray {
}

- (void)gameDidStart {
    [self performSegueWithIdentifier:@"prepareRoomViewGotoGamePlayView" sender:self];
}

#pragma UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *clientViewIdentifier = @"WMClientView";
    WMClientView *cell = (WMClientView *)[collectionView dequeueReusableCellWithReuseIdentifier:clientViewIdentifier forIndexPath:indexPath];
    WMClient * client = nil;
    NSArray * currentClients = [[WMPrepareRoom defaultRoom] clients];
    NSString * avatar;
    NSString * name;
    if ([currentClients count] >= indexPath.row + 1) {
        client = [currentClients objectAtIndex:indexPath.row];
        avatar = client.avatarPath;
        name = client.name;
    }

    [cell configureCellWithAvatarURL:avatar andName:name];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.peopleCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


@end
