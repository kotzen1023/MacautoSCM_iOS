//
//  NotifyItem.m
//  Macauto_SCM
//
//  Created by SUNUP on 2017/3/8.
//  Copyright © 2017年 RichieShih. All rights reserved.
//

#import "NotifyItem.h"

@implementation NotifyItem

-(void) setTitle:(NSString *)s_title
{
    title = s_title;
}

-(void) setMsg:(NSString *)s_msg
{
    msg = s_msg;
}

-(void) setTime:(NSString *)s_time
{
    time = s_time;
}

-(void) setReadSp:(NSString *)s_sp
{
    sp = s_sp;
}


-(NSString *) title
{
    return title;
}

-(NSString *) msg
{
    return msg;
}

-(NSString *) time
{
    return time;
}

-(NSString *) sp
{
    return sp;
}

@end
