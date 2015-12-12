//
//  TimeAndCoordinateInfo.m
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "TimeAndCoordinateInfo.h"

@implementation TimeAndCoordinateInfo
-(NSTimeInterval)subDate:(NSDate*) firstDate  secondDate :(NSDate*) secondDate
{
    NSInteger seconds = [firstDate timeIntervalSinceDate:secondDate];
    return seconds/60;/*秒转换成分钟*/
}
@end
