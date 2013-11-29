//
//  WMHostInitViewController.m
//  Pepsi
//
//  Created by Wraecca on 2013/11/29.
//  Copyright (c) 2013年 WOOMOO. All rights reserved.
//

#import "WMHostInitViewController.h"
#import "WMPrepareRoomViewController.h"

@interface WMHostInitViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, assign) NSInteger peopleCount;
@property (nonatomic, strong) IBOutlet UIPickerView * picker;
@end

@implementation WMHostInitViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.picker selectRow:5 inComponent:0 animated:NO];
    self.peopleCount = [self.picker selectedRowInComponent:0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"hostInitViewGotoWaitingRoomView"]) {
        UINavigationController * nav = (UINavigationController*)segue.destinationViewController;
        UIViewController * vc = nav.topViewController;
        if ([vc isKindOfClass:[WMPrepareRoomViewController class]]) {
            WMPrepareRoomViewController * prepareRoomVC = (WMPrepareRoomViewController*)vc;
            prepareRoomVC.peopleCount = self.peopleCount;
            prepareRoomVC.isHost = YES;
        }
        
    }
}

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 20;
}

#pragma mark UIPickerViewDataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = [NSString stringWithFormat:@"%li", (long)row];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.peopleCount = row;
}

@end
