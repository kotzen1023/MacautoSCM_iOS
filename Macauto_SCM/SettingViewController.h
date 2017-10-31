//
//  SettingViewController.h
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/8.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *btnImgLogout;
@property (weak, nonatomic) IBOutlet UIButton *btnTextLogout;

- (IBAction)btnImageAction:(id)sender;
- (IBAction)btnTextAction:(id)sender;

@property NSString *user_id;

@end
