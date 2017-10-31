//
//  SettingViewController.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/8.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "SettingViewController.h"
#import "Firebase.h"

@interface SettingViewController ()



@end

@implementation SettingViewController
@synthesize user_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    user_id = [defaults objectForKey:@"Account"];
    
    [_btnTextLogout setTitle:NSLocalizedString(@"SETTING_LOGOUT", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnImageAction:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SETTING_LOGOUT_ALERT_TITLE", nil)
        message:NSLocalizedString(@"SETTING_LOGOUT_ALERT_MSG", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        NSString *topic = [NSString stringWithFormat:@"/topics/%@", user_id];
        
        [[FIRMessaging messaging] unsubscribeFromTopic:topic];
        NSLog(@"Unsubscribed topic: %@", topic);
        
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:yesBtn];
    [alert addAction:cancelBtn];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)btnTextAction:(id)sender {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SETTING_LOGOUT_ALERT_TITLE", nil)
                                                                    message:NSLocalizedString(@"SETTING_LOGOUT_ALERT_MSG", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        NSString *topic = [NSString stringWithFormat:@"/topics/%@", user_id];
        
        [[FIRMessaging messaging] unsubscribeFromTopic:topic];
        NSLog(@"Unsubscribed topic: %@", topic);
        
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:NSLocalizedString(@"COMMON_CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:yesBtn];
    [alert addAction:cancelBtn];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
