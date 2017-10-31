//
//  ThemeColor.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/5.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "ThemeColor.h"

@implementation ThemeColor

- (UIColor *) getDefault_color_button
{
    default_color_button = [UIColor colorWithRed:0 green:0.478431 blue:1.000000 alpha:1.0];
    return default_color_button;
}

- (UIColor *) getDefault_color_background
{
    default_color_background = [UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1.0];
    return default_color_background;
}

@end
