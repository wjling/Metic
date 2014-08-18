//
//  MapViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-14.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MapViewController.h"
#import "../Source/SlideNavigationController.h"
#import "LaunchEventViewController.h"


@interface MapViewController ()
@property (nonatomic,strong) BMKPointAnnotation *panPoint;
@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic,strong) BMKLocationService* locService;
@end



@implementation MapViewController
//@synthesize mapView;


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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    _locService = [[BMKLocationService alloc]init];

    
 
	

}

-(void)viewWillAppear:(BOOL)animated {
    [mapView viewWillAppear];
    [((SlideNavigationController*)self.navigationController) setEnableSwipeGesture:NO];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    mapView.centerCoordinate = _position;
    mapView.mapType = BMKMapTypeStandard;
    _locService.delegate = self;
    _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    _geoCodeSearch.delegate = self;
    
    _panPoint = [[BMKPointAnnotation alloc] init];
    _panPoint.coordinate = _position;
    _panPoint.title = _positionInfo;
    [mapView addAnnotation:_panPoint];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [mapView viewWillDisappear];
    [_locService stopUserLocationService];
    mapView.delegate = nil; // 不用时，置nil
    _geoCodeSearch.delegate = nil;
    [((SlideNavigationController*)self.navigationController) setEnableSwipeGesture:YES];
}


- (void)dealloc {
    if (mapView) {
        mapView.delegate = nil;
        _geoCodeSearch.delegate = nil;
    }
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
    [_locService stopUserLocationService];
    [mapView removeAnnotation:_panPoint];
    _panPoint.coordinate = coordinate;
    [mapView addAnnotation:_panPoint];
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	if (error == 0) {
        _panPoint.title = result.address;
        _positionInfo = result.address;
	}
}
- (IBAction)comfirmPosition:(id)sender {
    ((LaunchEventViewController*)_controller).pt = _position;
    ((LaunchEventViewController*)_controller).positionInfo = _positionInfo;
    [self.navigationController popToViewController:_controller animated:YES];
}

- (IBAction)getLocation:(id)sender {
    [_locService startUserLocationService];
    mapView.showsUserLocation = NO;
    mapView.userTrackingMode = BMKUserTrackingModeNone;
    mapView.showsUserLocation = YES;
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    [mapView updateLocationData:userLocation];
    
    [mapView removeAnnotation:_panPoint];
    _panPoint.coordinate = userLocation.location.coordinate;
    [mapView addAnnotation:_panPoint];
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}
@end

