//
//  HistoryTimeInfo.h
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrentTimeInfo;

@interface HistoryTimeInfo : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * totalMinute;
@property (nonatomic, retain) NSSet *currentTimeInfo;
@end

@interface HistoryTimeInfo (CoreDataGeneratedAccessors)

- (void)addCurrentTimeInfoObject:(CurrentTimeInfo *)value;
- (void)removeCurrentTimeInfoObject:(CurrentTimeInfo *)value;
- (void)addCurrentTimeInfo:(NSSet *)values;
- (void)removeCurrentTimeInfo:(NSSet *)values;

@end
