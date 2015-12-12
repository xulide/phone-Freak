//
//  CurrentMapViewController.h
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import  <MapKit/MKAnnotation.h>

//@class subMKMapView;
@interface KCAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
//@property (nonatomic, copy,readonly) subMKMapView *mKMapView;
@end


#import <UIKit/UIKit.h>

@interface CurrentMapViewController : UIViewController
-(id)initWithData:(NSArray *)tableSourceArray withTitle:(NSString*)title;
@end
