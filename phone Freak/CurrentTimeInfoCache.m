//
//  CurrentTimeInfoCache.m
//  phone Freak
//
//  Created by xulide on 15/9/14.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import "CurrentTimeInfo.h"
#import "CurrentTimeInfoCache.h"

@implementation CurrentTimeInfoCache

-(void)currentTimeInfoToCurrentTimeInfoCache:(CurrentTimeInfo*)currentTimeInfo
{
    if (!currentTimeInfo)
    {
        return;
    }
    
    @autoreleasepool
    {
        NSTimeInterval subTimeIntervalMinute = [currentTimeInfo.endTime timeIntervalSinceDate :currentTimeInfo.startTime ]/60; /*秒转换成分钟*/
        
        NSString *startTime = [currentTimeInfo.startTime description];
        NSString *endTime = [currentTimeInfo.endTime description];

        NSArray *formatStartTimeArray = [startTime componentsSeparatedByString:@" "];
        NSArray *formatEndTimeArray = [endTime componentsSeparatedByString:@" "];
        
        startTime = formatStartTimeArray[1];
        endTime = formatEndTimeArray[1];
        
        formatStartTimeArray = [startTime componentsSeparatedByString:@":"];
        formatEndTimeArray = [endTime componentsSeparatedByString:@":"];
        
        NSString *formatStartTime = [formatStartTimeArray[0]  stringByAppendingFormat :@":%@",formatStartTimeArray[1]];
        
        NSString *formatEndTime = [formatEndTimeArray[0]  stringByAppendingFormat :@":%@",formatEndTimeArray[1]];
        
        _textLabel = [NSString stringWithFormat: @"%@   %@",formatStartTime,formatEndTime];
        
        _detailTextLabel = [[NSString stringWithFormat: @"  %f",subTimeIntervalMinute] componentsSeparatedByString:@"."][0];
        
        _latitude = currentTimeInfo.latitude;
        _longitude = currentTimeInfo.longitude;
    }
}
@end
