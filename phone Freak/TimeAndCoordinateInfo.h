//
//  TimeAndCoordinateInfo.h
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeAndCoordinateInfo : NSObject
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
-(NSTimeInterval)subDate:(NSDate*) firstDate  secondDate :(NSDate*) secondDate;//firstDate - secondDate
@end
