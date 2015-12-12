//
//  CurrentTimeInfo.m
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "CurrentTimeInfo.h"
#import "HistoryTimeInfo.h"


@implementation CurrentTimeInfo

@dynamic endTime;
@dynamic latitude;
@dynamic longitude;
@dynamic startTime;
@dynamic historyTimeInfo;

+(NSString *)description
{
    return  @"CurrentTimeInfo";
}
@end
