//
//  NotifyItem.h
//  Macauto_SCM
//
//  Created by SUNUP on 2017/3/8.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotifyItem : NSObject {
    NSString *title;
    NSString *msg;
    NSString *time;
    NSString *sp;
}

-(void) setTitle:(NSString *) s_title;
-(void) setMsg:(NSString *) s_msg;
-(void) setTime:(NSString *) s_time;
-(void) setReadSp:(NSString *) s_sp;

-(NSString *) title;
-(NSString *) msg;
-(NSString *) time;
-(NSString *) sp;

@end
