//
//  CurrentTimeInfoCache.h
//  phone Freak
//
//  Created by xulide on 15/9/14.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CurrentTimeInfo;
@interface CurrentTimeInfoCache : NSObject
//@property (strong, nonatomic)NSMutableArray * tableSourceArray;
@property (strong,nonatomic) NSString *textLabel;
@property (strong,nonatomic)NSString *detailTextLabel;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
-(void)currentTimeInfoToCurrentTimeInfoCache:(CurrentTimeInfo*)currentTimeInfo;
@end
