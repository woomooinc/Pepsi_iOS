//
//  WMClientViewCell.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMClientViewCell.h"
#import "UIImageView+WebCache.h"
#import "WMBlueToothController.h"

@implementation WMClientViewCell

- (void)configureCellWithClient:(WMClient*)client {
    if (!client.name) {
        // keep waiting!
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
        self.nameLabel.text = @"Waiting...";
        self.avatarView.image = nil;
    }
    else {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
        self.nameLabel.text = client.name;
        
        [self.avatarView setImageWithURL:[NSURL URLWithString:client.avatarPath ]
                        placeholderImage:client.placeholder
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               }];
        self.scoreLabel.text = [NSString stringWithFormat:@"%i", client.score];
        
        // calculate image scale
        /*
         WMBlueToothController * ble = [WMBlueToothController sharedController];
         if ([ble totalScore] != 0) {
         CGFloat scale = score * [[ble clients] count] / [ble totalScore];
         self.avatarView.transform = CGAffineTransformMakeScale(scale, scale);
         }
         */
    }
    
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.masksToBounds = YES;
    
    [self layoutIfNeeded];
}

- (void)showWinner {
    
}

- (void)showLoser {
    CIImage *beginImage = [CIImage imageWithCGImage:self.avatarView.image.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *exposure = [CIFilter filterWithName:@"CIExposureAdjust"
                                    keysAndValues:kCIInputImageKey, beginImage, @"inputEV", [NSNumber numberWithFloat:0.8], nil];
    CIImage *exposuredImage = [exposure outputImage];
    
    CIFilter *saturation = [CIFilter filterWithName:@"CIColorControls"
                                      keysAndValues:kCIInputImageKey, exposuredImage, @"inputSaturation", [NSNumber numberWithFloat:0.0], nil];
    CIImage *outputImage = [saturation outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *filterImage = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    self.avatarView.image = filterImage;
}
@end
