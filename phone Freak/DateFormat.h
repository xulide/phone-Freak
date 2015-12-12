//
//  DateFormat.h
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormat : NSObject
- (NSArray *)calculateDateToDifferentDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate;
//+(instancetype)shareInstance;
- (NSDate *)formatDateToMinute:(NSDate *)date;
- (NSDate *)formatDateToDay:(NSDate *)date;
- (NSString *)dateToValidStringDescription:(NSDate *)date;
@end
