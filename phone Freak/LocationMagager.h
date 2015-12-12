//
//  LocationMagager.h
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LocationMagager : NSObject
@property (nonatomic,assign) BOOL backgroundFlag;
@property (atomic,assign) BOOL isOneTimeStart;
-(void)startLocation;
-(void)startLocationWithHeart;
-(void)stopLocation;
+(instancetype)shareInstance;
@end
