//
//  OpeningViewController.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/4.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "OpeningViewController.h"

@interface OpeningViewController ()


@end

@implementation OpeningViewController
@synthesize subview;
@synthesize tapRecognizer;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSLog(@"OpeningViewController viewDidLoad");
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *uuid = [[currentDevice identifierForVendor] UUIDString];
    
    NSLog(@"uuid  = %@", uuid);
    
    // load defaults to input
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _account = [defaults objectForKey:@"Account"];
    _deviceId = [defaults objectForKey:@"DeviceID"];
    
    if (_account != nil && ![_account isEqualToString: @""])
        NSLog(@"account = %@", _account);
    else
        NSLog(@"account = null");
    
    if (_deviceId != nil && ![_deviceId isEqualToString:@""])
        NSLog(@"device id = %@", _deviceId);
    else
        NSLog(@"device id = null");
    
    [_header setAlpha: 0.0f];
    
    
    [UIView animateWithDuration:2.0 animations:^{
        [_header setAlpha:1.0f];
        _header.text = NSLocalizedString(@"MACAUTO_SCM", nil);
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:2.0f animations:^{
            
            [_header setAlpha: 0.0f];
            
            
        } completion:^(BOOL finished) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            if (_account != nil && ![_account isEqualToString: @""] &&
                _deviceId != nil && ![_deviceId isEqualToString:@""]) {
                
                UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [self presentViewController:vc animated:YES completion:nil];
            }
            
            
        }];
        
    }];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleTap:)];
    [subview addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        //code here
        NSLog(@"subview touched");
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if (_account != nil && ![_account isEqualToString: @""] &&
            _deviceId != nil && ![_deviceId isEqualToString:@""]) {
            
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
