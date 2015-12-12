//
//  CurrentTimeInfo.h
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HistoryTimeInfo;

@interface CurrentTimeInfo : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) HistoryTimeInfo *historyTimeInfo;

@end
