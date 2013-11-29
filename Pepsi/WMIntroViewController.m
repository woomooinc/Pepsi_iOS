//
//  WMIntroViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/30.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMIntroViewController.h"
#import "WMClient.h"
#import <CommonCrypto/CommonDigest.h>

@interface WMIntroViewController ()

@end

@implementation WMIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kWMName]) {
        [self performSegueWithIdentifier:@"introViewGotoHostIntiView" sender:self];
    }
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString * name = textField.text;
    
    const char *cStr = [name UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", digest[i]];
    }
    NSString * avatar = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@", hash];

    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kWMName];
    [[NSUserDefaults standardUserDefaults] setObject:avatar forKey:kWMAvatar];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"introViewGotoHostIntiView" sender:self];
    return YES;
}

@end
