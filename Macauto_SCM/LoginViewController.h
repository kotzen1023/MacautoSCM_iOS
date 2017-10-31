//
//  LoginViewController.h
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/4.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <NSXMLParserDelegate, NSURLSessionDelegate, UITextFieldDelegate> {
    
    UITextField *textInputID;
    UITextField *textInputPassword;
    
    UILabel *activityLabel;
    UIActivityIndicatorView *activityIndicator;
    UIView *container;
    CGRect frame;
}

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;

- (IBAction)nameInputDone:(id)sender;

- (IBAction)passwordInputDone:(id)sender;


@property NSMutableArray *loginlSCM;

@property UIActivityIndicatorView *activityIndicator;
@property NSString *uuid;

-(id) initWithFrame:(CGRect) theFrame;

- (IBAction)btnLogin:(id)sender;
- (IBAction)btnClear:(id)sender;

- (NSMutableArray *) sendHttpPost;
@end
