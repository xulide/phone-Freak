//
//  SharedTimeAndCoordinateInfo.h
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
static  NSString * TimeAndCoordinateInfoUpdateNotification = @"UpdateTimeAndCoordinateInfo";
@class TimeAndCoordinateInfo;
@interface SharedTimeAndCoordinateInfo : NSObject
+(instancetype) shareInstance;
@property(strong,nonatomic) NSMutableDictionary *timeAndCoordinateInfoDictionary;
-(void) insertTimeAndCoordinateInfo:(NSString *)time TimeAndCoordinateInfo:(TimeAndCoordinateInfo *)timeAndCoordinateInfoInstance;
-(NSMutableDictionary *)getTimeAndCoordinateInfo;
@end
