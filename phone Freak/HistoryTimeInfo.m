//
//  HistoryTimeInfo.m
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "HistoryTimeInfo.h"
#import "CurrentTimeInfo.h"


@implementation HistoryTimeInfo

@dynamic time;
@dynamic totalMinute;
@dynamic currentTimeInfo;

+(NSString *)description
{
    return  @"HistoryTimeInfo";
}
@end
