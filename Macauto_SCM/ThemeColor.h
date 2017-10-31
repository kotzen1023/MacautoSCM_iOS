//
//  ThemeColor.h
//  Macauto_SCM
//
//  Created by SUNUP on 2017/5/5.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#ifndef ThemeColor_h
#define ThemeColor_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ThemeColor : NSObject
{
    UIColor *default_color_button;
    UIColor *default_color_background;
}

-(UIColor *) getDefault_color_button;
-(UIColor *) getDefault_color_background;

@end

#endif /* ThemeColor_h */
