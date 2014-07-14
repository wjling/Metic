//
//  MapViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-14.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BMapKit.h"
#import "BMKMapView.h"

@interface MapViewController : UIViewController <BMKMapViewDelegate>{

    IBOutlet BMKMapView *mapView;

}
@end
