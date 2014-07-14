//
//  MapViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-14.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MapViewController.h"
#import "../Source/SlideNavigationController.h"


@interface MapViewController ()

@end


@implementation MapViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [((SlideNavigationController*)self.navigationController) setEnableSwipeGesture:NO];
 
	

}

-(void)viewWillAppear:(BOOL)animated {
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
//    [_mapView showMapScaleBar];
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){40.0,116.0};
    mapView.centerCoordinate = pt;
    mapView.mapType = BMKMapTypeSatellite;
}

-(void)viewWillDisappear:(BOOL)animated {
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
    [((SlideNavigationController*)self.navigationController) setEnableSwipeGesture:YES];
}


- (void)dealloc {
    if (mapView) {
        mapView.delegate = nil;
        mapView = nil;
    }
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




@end

