//
//  CurrentMapViewController.m
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>
#import "CurrentMapViewController.h"
#import "MapKit/MKMapView.h"
#import "UIViewController+getCurrentVisibleController.h"
#import "subMKMapView.h"
#import "CurrentTimeInfoCache.h"
#import "UIViewController+RegisterNotification.h"
@interface CurrentMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic)NSArray * tableSourceArray;
@end

@implementation KCAnnotation
@end

@implementation CurrentMapViewController


-(subMKMapView *)mKMapView
{
    return (subMKMapView*)self.view;
}

-(id)initWithData:(NSArray *)tableSourceArray withTitle:(NSString*)title
{
    NSLog(@"CurrentMapViewController init");
    
    if(self = [super init])
    {
        _tableSourceArray = tableSourceArray;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mKMapView.delegate = self;
    
    __block CLLocationCoordinate2D centerCoordinate;
    
    [_tableSourceArray enumerateObjectsUsingBlock:^(CurrentTimeInfoCache * currentTimeInfoCache, NSUInteger idx, BOOL *stop) {
        
        CLLocationCoordinate2D coordinate = {currentTimeInfoCache.latitude.doubleValue,currentTimeInfoCache.longitude.doubleValue};
        NSLog(@"viewDidLoad latitude = %f longitude = %f",coordinate.latitude,coordinate.longitude);
        [self addAnnotation:coordinate title:currentTimeInfoCache.textLabel subtitle:currentTimeInfoCache.detailTextLabel];
        
        if (0 == idx)
        {
            centerCoordinate = coordinate;
        }
    }];
    
    self.mKMapView.mapType = MKMapTypeStandard;
    
    MKCoordinateRegion regoin = MKCoordinateRegionMake(centerCoordinate, MKCoordinateSpanMake(0.5, 0.5));
    
    [self.mKMapView setRegion:regoin animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
     NSLog(@"-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation");
}

- (void)didReceiveMemoryWarning
{
        NSLog(@"**********call %@ %@ start",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    if (self != [self getCurrentVisibleController])
    {
        self.view = nil;
        self.tableSourceArray = nil;
    }
        NSLog(@"**********call %@ %@ end",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

-(void)addAnnotation:(CLLocationCoordinate2D) location  title:(NSString *)title  subtitle:(NSString *)subtitle
{
    KCAnnotation *annotation=[[KCAnnotation alloc]init];
    annotation.title=title;
    annotation.subtitle=subtitle;
    annotation.coordinate=location;

    [self.mKMapView addAnnotation:annotation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"**********call %@ %@ start",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [super viewDidDisappear : animated];
    self.mKMapView.mapType = MKMapTypeHybrid;
    self.mKMapView.showsUserLocation = NO;
   
    self.mKMapView.delegate = nil ;
    [self.mKMapView removeFromSuperview];
    self.view = nil;
    self.tableSourceArray = nil;

}

- (void)dealloc
{
    NSLog(@"CurrentMapViewController dealloc");
}

@end
