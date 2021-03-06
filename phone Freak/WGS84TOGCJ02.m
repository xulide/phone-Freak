//
//  WGS84TOGCJ02.m
//  phone Freak
//
//  Created by xulide on 15/9/20.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "WGS84TOGCJ02.h"

#import "WGS84TOGCJ02.h"

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;

@implementation WGS84TOGCJ02

//+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc
//{
//    CLLocationCoordinate2D adjustLoc;
//    if([self isLocationOutOfChina:wgsLoc]){
//        adjustLoc = wgsLoc;
//    }else{
//        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
//        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
//        double radLat = wgsLoc.latitude / 180.0 * pi;
//        double magic = sin(radLat);
//        magic = 1 - ee * magic * magic;
//        double sqrtMagic = sqrt(magic);
//        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
//        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
//        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
//        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
//    }
//    return adjustLoc;
//}
//
////判断是不是在中国
//+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
//{
//    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
//        return YES;
//    return NO;
//}
//
//+(double)transformLatWithX:(double)x withY:(double)y
//{
//    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
//    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
//    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
//    lat += (160.0 * sin(y / 12.0 * pi) + 3320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
//    return lat;
//}
//
//+(double)transformLonWithX:(double)x withY:(double)y
//{
//    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
//    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
//    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
//    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
//    return lon;
//}


-(id)init
{
    if(self = [super init])
    {
        _sqlite = [[CSqlite alloc]init];
        [_sqlite openSqlite];
        
    }
    return self;
}

-(void)dealloc
{
    [_sqlite  closeSqlite];
}


//+(id)shareInstance
//{
//    static WGS84TOGCJ02 *WGS84TOGCJ02_INSTANCE ;
//    static dispatch_once_t onceflag;
//    dispatch_once(&onceflag, ^{
//        WGS84TOGCJ02_INSTANCE = [WGS84TOGCJ02 new];
//    });
//    return WGS84TOGCJ02_INSTANCE;
//}

-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(yGps.latitude*10);
    TenLog = (int)(yGps.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
    NSLog(@"SQL = %@",sql);
    sqlite3_stmt* stmtL = [_sqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
        
    }
    sqlite3_finalize(stmtL);
    yGps.latitude = yGps.latitude+offLat*0.0001;
    yGps.longitude = yGps.longitude + offLog*0.0001;
    return yGps;
    
    
}
@end
