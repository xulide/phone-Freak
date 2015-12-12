//
//  DateFormat.m
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "DateFormat.h"
@interface DateFormat()
@property (strong,nonatomic)NSTimeZone *zone ;
@property (strong,nonatomic)NSDateFormatter * dateFormatter;
@property (strong,nonatomic)NSDateFormatter * dateFormatterFirst;
@property (strong,nonatomic)NSDateFormatter * dateFormatterSecond;
@end

@implementation DateFormat

-(id)init
{
    if (self = [super init])
    {
        _zone = [NSTimeZone systemTimeZone];
        
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _dateFormatterFirst = [[NSDateFormatter alloc]init];
        [_dateFormatterFirst setDateFormat:@"yyyy-MM-dd 23:59:00"];
        
        _dateFormatterSecond = [[NSDateFormatter alloc]init];
        [_dateFormatterSecond setDateFormat:@"yyyy-MM-dd  00:00:00"];
    }
    
    return self;
}

//+(instancetype)shareInstance
//{
//    static DateFormat *dateFormat;
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        dateFormat = [DateFormat new];
//    });
//    return dateFormat;
//}


- (NSDate *)formatDateToMinute:(NSDate *)date
{
    NSTimeInterval interval = [self extractDateToTimeInterval:date];
    static int daySeconds =  60;
    //calculate integer type of days
    NSInteger allDays = interval / daySeconds;
    
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}

/*时间格式化成天的形式*/
- (NSDate *)formatDateToDay:(NSDate *)date
{
    NSTimeInterval interval = [date timeIntervalSince1970];
    static int daySeconds =  24*60*60;
    //calculate integer type of days
    NSInteger allDays = interval / daySeconds;
    
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}

- (NSTimeInterval)extractDateToTimeInterval:(NSDate *)date
{
    NSInteger intervalZone = [_zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: intervalZone];
    //get seconds since 1970
    NSTimeInterval interval = [localeDate timeIntervalSince1970];
    return  interval;
}

/*输入参数是经过8小时时差计算，并且格式化成分钟形式*/
- (NSArray *)calculateDateToDifferentDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate
{
    NSDate * firstFormatDate = [self formatDateToDay: firstDate];
    NSDate * seconFormatdDate = [self formatDateToDay: secondDate];
    
    NSArray * array = nil;
    
    if (![firstFormatDate isEqual:seconFormatdDate])
    {
        NSString *firstDateString=[_dateFormatterFirst stringFromDate:firstFormatDate];
        
        NSString *secondDateString=[_dateFormatterSecond stringFromDate:seconFormatdDate];
        
        NSDate * firstDate = [_dateFormatter dateFromString:firstDateString];
        
        firstDate=[self formatDateToMinute:firstDate];
        
        NSDate * secondDate = [_dateFormatter dateFromString:secondDateString];
        
        secondDate=[self formatDateToMinute:secondDate];
        
        array = @[firstDate, secondDate];
    }
    
    return array;
}

- (NSString *)dateToValidStringDescription:(NSDate *)date
{
    if (date)
    {
        return [[date description] componentsSeparatedByString:@" "][0];
    }
    else
    {
        return nil;
    }
}

@end
