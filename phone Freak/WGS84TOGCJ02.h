//
//  WGS84TOGCJ02.h
//  phone Freak
//
//  Created by xulide on 15/9/20.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CSqlite.h"
@interface WGS84TOGCJ02 : NSObject
//+(id)shareInstance;
////判断是否已经超出中国范围
//+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
////转GCJ-02
//+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps;
@property(strong,nonatomic)CSqlite *sqlite;
@end
