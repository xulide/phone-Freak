//
//  LocationMagager.m
//  phone Freak
//
//  Created by xulide on 15/8/30.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import "StateContext.h"
#import "LocationMagager.h"
#import<CoreLocation/CoreLocation.h>
#import<CoreLocation/CLLocationManagerDelegate.h>
#import <UIKit/UIDevice.h>
#import "WGS84TOGCJ02.h"

static const double DISTANCE_FILTER = 300.0f;

@interface LocationMagager ()<CLLocationManagerDelegate>
@property(strong,nonatomic) CLLocationManager *manager;
@property(assign,atomic) BOOL startUpdateFlag;
@end
@implementation LocationMagager
{
    CLLocation *prevLocation;
}
-(id)init
{
    if (self = [super init])
    {
         if ([CLLocationManager locationServicesEnabled])
         {
             
            _manager = [[CLLocationManager alloc] init];//初始化定位器
            [_manager setDelegate: self];//设置代理
            [_manager setDesiredAccuracy: kCLLocationAccuracyBest];//设置精确度
             _manager.distanceFilter =DISTANCE_FILTER;
            _startUpdateFlag = NO;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                [_manager requestAlwaysAuthorization];  //调用了这句,就会弹出允许框了.
            }
             
             _manager.allowsBackgroundLocationUpdates = YES;
         }
    }

    return self;
}

+(instancetype)shareInstance
{
    static LocationMagager *locationMagager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        locationMagager = [LocationMagager new];
    });
    return locationMagager;
}

-(void)startLocation
{
    NSLog(@"***********startLocation**************");
    _startUpdateFlag = YES;
    prevLocation = [[CLLocation alloc] initWithLatitude:0.0f longitude:0.0f];
    [self.manager startUpdatingLocation];
}

-(void)startLocationWithHeart
{
    NSLog(@"***********startLocationHeart**************");
    [self.manager startUpdatingLocation];
}


-(void)stopLocation
{
    NSLog(@"***********stopLocation**************");
    _startUpdateFlag = NO;
    [[StateContext shareInstance] changeToIdle];
//  [self.manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"&&&&&&&&&&&&&&&&didUpdateLocations&&&&&&&&&&&&&&&&");
    
    CLLocation *newLocation = [locations lastObject];
    /*有效的定位参数*/
    if (!newLocation || !_startUpdateFlag)
    {
        return;
    }

    // 计算距离
    CLLocationDistance distanceMeters=[newLocation distanceFromLocation:prevLocation];
    
    /*前后两次距离小于100m,直接返回*/
    if (distanceMeters < DISTANCE_FILTER)
    {
        return;
    }

    if (newLocation.horizontalAccuracy > 0)
    {
        CLLocationCoordinate2D  coordinate2D = newLocation.coordinate;

        prevLocation = newLocation;
        
        CLLocationCoordinate2D coord = [[WGS84TOGCJ02 new] zzTransGPS:coordinate2D];
        [[StateContext shareInstance] changeToRunning:coord];
        NSLog(@"GCJ02 :latitude = %f  longitude = %f",coord.latitude,coord.longitude);
        NSLog(@"horizontalAccuracy = %f latitude = %f  longitude = %f",newLocation.horizontalAccuracy,coordinate2D.latitude,coordinate2D.longitude);
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
   NSLog(@"didFailWithError startLocation NSThread = %@  error = %@",[NSThread currentThread],error);
}


@end
