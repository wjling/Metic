//
//  LaunchEventViewController.m
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LaunchEventViewController.h"
#import "InviteFriendViewController.h"
#import "MapViewController.h"
#import "MTUser.h"
#import "CommonUtils.h"




@interface LaunchEventViewController ()
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *datePickerView;
@property (nonatomic,strong) UITextField *seletedText;
@property (nonatomic,strong) MTUser *user;
@property (nonatomic,strong) NSMutableSet *FriendsIds;
@property (nonatomic,strong) NSDictionary* positions;
@property (nonatomic,strong) NSDictionary* locationInfo;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *getLocIndicator;
@property (strong, nonatomic) IBOutlet UIButton *getLocButton;
//@property (strong, nonatomic) BMKMapManager* mapManager;
@property (strong, nonatomic) BMKGeoCodeSearch* geocodesearch;
@property (nonatomic, strong) BMKLocationService* locService;
@property (strong, nonatomic) BMKMapManager *mapManager;
@property (strong, nonatomic) UIImage* uploadImage;
@property (strong, nonatomic) UIView* waitingView;
@property (nonatomic, strong) FlatDatePicker *flatDatePicker;


@end

@implementation LaunchEventViewController
@synthesize mapManager;
//double longitude = 999.999999;
//double latitude = 999.999999;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self turnRoundCorner];
    self.scrollView.delegate = self;
    self.begin_time_text.delegate = self;
    self.end_time_text.delegate = self;
    self.event_text.delegate = self;
    self.location_text.delegate = self;
    self.detail_text.delegate = self;
    self.user = [MTUser sharedInstance];
    [self.canin setOn:NO];
    self.FriendsIds = [[NSMutableSet alloc]init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mapManager = appDelegate.mapManager;
    
    BOOL ret = [mapManager start:@"mk9WfL1PxXjguCdYsdW7xQYc" generalDelegate:nil];
	if (!ret) {
		NSLog(@"manager start failed!");
	}

    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    self.pt = (CLLocationCoordinate2D){999.999999, 999.999999};
    self.positionInfo = @"";
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    self.flatDatePicker.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    _locService.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    _geocodesearch.delegate = self;
    _flatDatePicker.delegate = self;
    self.location_text.text = self.positionInfo;
}


-(void)viewDidDisappear:(BOOL)animated
{
    _geocodesearch.delegate = nil;
    _locService.delegate = nil;
    _flatDatePicker.delegate = nil;
    [_locService stopUserLocationService];
}

-(void)dealloc
{
    _geocodesearch.delegate = nil;
    
    [mapManager stop];
    NSLog(@"delete");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)turnRoundCorner
{
    for (UIView*view in self.roundCornerView) {
        view.layer.cornerRadius = 5;
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.scrollView.contentOffset = CGPointMake(0, textView.frame.origin.y - 55);
    
    return YES;
}

-(void)showWaitingView
{
    if (!_waitingView) {
        CGRect frame = self.view.bounds;
        _waitingView = [[UIView alloc]initWithFrame:frame];
        [_waitingView setBackgroundColor:[UIColor blackColor]];
        [_waitingView setAlpha:0.5f];
        frame.origin.x = (frame.size.width - 100)/2.0;
        frame.origin.y = (frame.size.height - 100)/2.0;
        frame.size = CGSizeMake(100, 100);
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:frame];
        [indicator setTag:101];
        [_waitingView addSubview:indicator];
    }
    
    [self.view addSubview:_waitingView];
    [((UIActivityIndicatorView*)[_waitingView viewWithTag:101]) startAnimating];
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [((UIActivityIndicatorView*)[_waitingView viewWithTag:101]) stopAnimating];
        [_waitingView removeFromSuperview];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if (textField.tag == 11) {
        [self.scrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - 100) animated:YES];
        [self.scrollView setUserInteractionEnabled:NO];
        self.flatDatePicker.title = @"请选择活动日期";
        NSDate *date;
        if (![textField.text isEqualToString:@""]) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            NSLog(@"#%@#",textField.text);
            date= [dateFormatter dateFromString:textField.text];
        }else date = [NSDate date];
        self.seletedText = textField;
        [self.flatDatePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:157680000]];
        self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;
        [self.flatDatePicker setDate:date animated:NO];
        [self.flatDatePicker show];
        return NO;
        
    }else{
        self.scrollView.contentOffset = CGPointMake(0, textField.superview.frame.origin.y - 100);
        return YES;
    }
}

- (void)closeDatePicker
{
    NSDate *curDate = [self.datePicker date];
    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *formateDateString = [formate stringFromDate:curDate];
    NSLog(@"%@",formateDateString);
    self.seletedText.enabled = YES;
    self.seletedText.text = formateDateString;
    
    [_datePickerView removeFromSuperview ];
}


- (IBAction)launch:(id)sender {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int duration = 0;
    int visibility = self.canin.isOn;
    int status = 0;
    NSString *friends = @"[";
    BOOL flag = YES;
    for (NSNumber* friendid in self.FriendsIds) {
        friends = [friends stringByAppendingString: flag? @"%@":@",%@"];
        if (flag) flag = NO;
        friends = [NSString stringWithFormat:friends,friendid];
    }
    friends = [friends stringByAppendingString:@"]"];
    
    
    self.event_text.text = [self.event_text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.event_text.text isEqualToString: @""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"活动发布失败" WithMessage:@"活动名不能为空" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    if ([self.begin_time_text.text isEqualToString: @""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"活动发布失败" WithMessage:@"活动开始时间不能为空" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    if ([self.end_time_text.text isEqualToString: @""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"活动发布失败" WithMessage:@"活动结束时间不能为空" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    [self showWaitingView];
    [sender setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverButton) userInfo:nil repeats:NO];
    [dictionary setValue:_user.userid forKey:@"id"];
    [dictionary setValue:self.subject_text.text forKey:@"subject"];
    [dictionary setValue:self.begin_time_text.text forKey:@"time"];
    [dictionary setValue:self.end_time_text.text forKey:@"endTime"];
    [dictionary setValue:self.detail_text.text forKey:@"remark"];
    [dictionary setValue:self.location_text.text forKey:@"location"];
    [dictionary setValue:[NSNumber numberWithInt:duration] forKey:@"duration"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithInt:visibility] forKey:@"visibility"];
    [dictionary setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    [dictionary setValue:friends forKey:@"friends"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LAUNCH_EVENT];
    
}

- (IBAction)getLoc:(id)sender {
    [self.getLocButton setHidden:YES];
    [self.getLocIndicator startAnimating];
    self.location_text.text = @"定位中";
    self.pt = (CLLocationCoordinate2D){23.114155, 113.318977};
    self.positionInfo = @"(^_^)";
    //[_locManager startUpdatingLocation];
    [_locService startUserLocationService];
    
}

- (IBAction)getBanner:(id)sender {
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

-(void) seletePosition
{
    [self performSegueWithIdentifier:@"map" sender:self];
    
}



-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	if (error == 0) {

        self.location_text.text = result.address;
        self.pt = result.location;
        self.positionInfo = result.address;
        
        [self.getLocIndicator stopAnimating];
        [self.getLocButton setImage:[UIImage imageNamed:@"地图定位后icon"] forState:UIControlStateNormal];
        [self.getLocButton removeTarget:self action:@selector(getLoc:) forControlEvents:UIControlEventAllEvents];
        [self.getLocButton addTarget:self action:@selector(seletePosition) forControlEvents:UIControlEventTouchUpInside];
        [self.getLocButton setHidden:NO];
	}
}



- (void) recoverButton
{
    [self.launch_button setEnabled:YES];
}

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.uploadImage;
    
    UIImage *image = self.uploadImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat wi = MIN(width, height*2.5);
    controller.imageCropRect = CGRectMake((width - wi) / 2,
                                          (height - wi*0.4) / 2,
                                          wi,
                                          wi*0.4);
    [controller setKeepingCropAspectRatio:YES];
    [controller setToolbarHidden:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
    
}

#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *value = [dateFormatter stringFromDate:date];
        self.seletedText.text = value;
    } else{
        if ([self.seletedText.text isEqualToString:@""]) {
            return;
        }
        [dateFormatter setDateFormat:@" HH:mm:ss"];
        NSString *value = [dateFormatter stringFromDate:date];
        value = [[self.seletedText.text substringToIndex:10] stringByAppendingString:value];
        self.seletedText.text = value;
    }
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    self.seletedText.text = @"";
    [self.scrollView setUserInteractionEnabled:YES];
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [datePicker setDatePickerMode:FlatDatePickerModeTime];
        [datePicker dismiss];
        [datePicker setTitle:@"请输入活动时间"];
        [datePicker show];
        return;
    } else if (datePicker.datePickerMode == FlatDatePickerModeTime) {
        //[datePicker setDatePickerMode:FlatDatePickerModeDate];
        [self.scrollView setUserInteractionEnabled:YES];
        return;
    }
    
}



#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self.banner_button setBackgroundImage:croppedImage forState:UIControlStateNormal];
    self.uploadImage = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.uploadImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    
}
#pragma mark - httpsender delegte
-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    NSNumber *tmpid = [response1 valueForKey:@"event_id"];
    if ([cmd intValue] != SERVER_ERROR && [tmpid intValue] != -1) {
        if (self.uploadImage) {
            PhotoGetter *getter = [[PhotoGetter alloc]initUploadMethod:self.uploadImage type:1];
            getter.mDelegate = self;
            [getter uploadBanner:[response1 valueForKey:@"event_id"]];
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布成功" WithDelegate:self WithCancelTitle:@"确定"];
        }
    }else{
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布失败" WithDelegate:nil WithCancelTitle:@"确定"];
    }
    
}
#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    if (type == 100){
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布成功" WithDelegate:self WithCancelTitle:@"确定"];
    }else if (type == 106){
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"活动发布成功，图片上传失败" WithDelegate:self WithCancelTitle:@"确定"];
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.destinationViewController isKindOfClass:[InviteFriendViewController class]]) {
        InviteFriendViewController *nextViewController = segue.destinationViewController;
        nextViewController.FriendsIds = self.FriendsIds;
        nextViewController.controller = self;
    }
    if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
        MapViewController *nextViewController = segue.destinationViewController;
        nextViewController.position = self.pt;
        nextViewController.positionInfo = self.positionInfo;
        nextViewController.controller = self;
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        [self removeWaitingView];
        [self.navigationController popToViewController:self.controller animated:YES];
    }
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{

    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        [self.getLocIndicator stopAnimating];
        [self.getLocButton setImage:[UIImage imageNamed:@"地图定位后icon"] forState:UIControlStateNormal];
        [self.getLocButton removeTarget:self action:@selector(getLoc:) forControlEvents:UIControlEventAllEvents];
        [self.getLocButton addTarget:self action:@selector(seletePosition) forControlEvents:UIControlEventTouchUpInside];
        [self.getLocButton setHidden:NO];
        NSLog(@"反geo检索发送失败");
    }
    [_locService stopUserLocationService];
}
/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self.getLocIndicator stopAnimating];
    [self.getLocButton setHidden:NO];
    self.location_text.text = @"";
    [self.getLocButton setImage:[UIImage imageNamed:@"地图定位后icon"] forState:UIControlStateNormal];
    [self.getLocButton removeTarget:self action:@selector(getLoc:) forControlEvents:UIControlEventAllEvents];
    [self.getLocButton addTarget:self action:@selector(seletePosition) forControlEvents:UIControlEventTouchUpInside];
    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"无法自动定位，请重试" WithDelegate:self WithCancelTitle:@"确定"];
}


@end
