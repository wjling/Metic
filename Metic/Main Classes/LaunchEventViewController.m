
//
//  LaunchEventViewController.m
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LaunchEventViewController.h"
#import "InviteFriendViewController.h"
#import "BannerSelectorViewController.h"
#import "HomeViewController.h"
#import "MapViewController.h"
#import "MTUser.h"
#import "CommonUtils.h"




@interface LaunchEventViewController ()
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *datePickerView;
@property (nonatomic,strong) UITextField *seletedText;
@property (nonatomic,strong) NSMutableSet *FriendsIds;
@property (nonatomic,strong) NSMutableArray *FriendsIds_array;
@property (nonatomic,strong) NSDictionary* positions;
@property (nonatomic,strong) NSDictionary* locationInfo;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *getLocIndicator;
@property (strong, nonatomic) IBOutlet UIButton *getLocButton;
@property (strong, nonatomic) BMKGeoCodeSearch* geocodesearch;
@property (nonatomic, strong) BMKLocationService* locService;
//@property (strong, nonatomic) BMKMapManager *mapManager;
@property (strong, nonatomic) UIView* waitingView;
@property (nonatomic, strong) FlatDatePicker *flatDatePicker;
@property int visibility;
@property BOOL isKeyBoard;
@property (nonatomic,strong) UIView* InviteFriendsView;
@property (nonatomic,strong) UIView* isAllowStrangerView;
@property (nonatomic,strong) UIButton *isAllowStrangerButton;
@property (strong,nonatomic) UICollectionView *collectionView;


@end

@implementation LaunchEventViewController
//@synthesize mapManager;
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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self turnRoundCorner];
    self.scrollView.delegate = self;
    self.begin_time_text.delegate = self;
    self.end_time_text.delegate = self;
    self.event_text.delegate = self;
    self.location_text.delegate = self;
    self.detail_text.delegate = self;
    [self initInviteFriendsView];
    _visibility = 0;
    _code = 1;
    _isKeyBoard = NO;
    self.FriendsIds = [[NSMutableSet alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    self.pt = (CLLocationCoordinate2D){999.999999, 999.999999};
    self.positionInfo = @"";
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    self.flatDatePicker.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MTdismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //_locService.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _geocodesearch.delegate = self;
    _flatDatePicker.delegate = self;
    self.location_text.text = self.positionInfo;
    [self copyFriendsId];
    [self adjustCollectionView];
    [_collectionView reloadData];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _geocodesearch.delegate = nil;
    _locService.delegate = nil;
    _flatDatePicker.delegate = nil;
    [_locService stopUserLocationService];
}

-(void)dealloc
{
    _geocodesearch.delegate = nil;
    
    //[mapManager stop];
    NSLog(@"delete");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)MTdismissKeyboard
{
    if (![_scrollView isUserInteractionEnabled] || !self.isKeyBoard) {
        return;
    }
    [_subject_text becomeFirstResponder];
    [_subject_text resignFirstResponder];
}

-(void)initInviteFriendsView
{
    _InviteFriendsView = [[UIView alloc]initWithFrame:CGRectMake(20, 560, 280, 70)];
    [_InviteFriendsView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    _InviteFriendsView.layer.cornerRadius = 5;
    [_scrollView addSubview:_InviteFriendsView];
    
    _isAllowStrangerView = [[UIView alloc]initWithFrame:CGRectMake(20, 640, 280, 40)];
    [_isAllowStrangerView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:_isAllowStrangerView];
    
    _isAllowStrangerButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    [_isAllowStrangerButton setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
    [_isAllowStrangerButton addTarget:self action:@selector(changeAllowStangerStage) forControlEvents:UIControlEventTouchUpInside];
    [_isAllowStrangerView addSubview:_isAllowStrangerButton];
    
    UILabel *isAllowStrangerLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 5, 200, 30)];
    [isAllowStrangerLabel setBackgroundColor:[UIColor clearColor]];
    isAllowStrangerLabel.text = @"允许陌生人参与";
    [isAllowStrangerLabel setFont:[UIFont systemFontOfSize:16]];
    [isAllowStrangerLabel setTextAlignment:NSTextAlignmentLeft];
    [_isAllowStrangerView addSubview:isAllowStrangerLabel];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(50,70);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 0, 270, 70) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"participantCell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_InviteFriendsView addSubview:_collectionView];
    
    
}

-(void)changeAllowStangerStage
{
    if (_visibility == 0) {
        _visibility = 1;
        [_isAllowStrangerButton setBackgroundImage:[UIImage imageNamed:@"允许陌生人"] forState:UIControlStateNormal];

    }else{
        _visibility = 0;
        [_isAllowStrangerButton setBackgroundImage:[UIImage imageNamed:@"不允许陌生人"] forState:UIControlStateNormal];
    }
}

-(void)copyFriendsId
{
    _FriendsIds_array = [[NSMutableArray alloc]init];
    for (NSNumber* fid in _FriendsIds) {
        [_FriendsIds_array addObject:fid];
    }
}

-(void)adjustCollectionView
{
    CGRect frame = _collectionView.frame;
    float count = _FriendsIds_array.count+1;
    frame.size.height = ceilf(count/5)*70;
    _collectionView.frame = frame;
    
    frame = _InviteFriendsView.frame;
    frame.size.height = ceilf(count/5)*70;
    _InviteFriendsView.frame = frame;
    
    frame = _isAllowStrangerView.frame;
    frame.origin.y = 570 + ceilf(count/5)*70;
    _isAllowStrangerView.frame = frame;
    
    if (_InviteFriendsView.frame.size.height + _InviteFriendsView.frame.origin.y + 60 > _scrollView.contentSize.height) {
        CGSize size = _scrollView.contentSize;
        size.height = _InviteFriendsView.frame.size.height + _InviteFriendsView.frame.origin.y + 60;
        _scrollView.contentSize = size;
        
    }
}

-(void)turnRoundCorner
{
    for (UIView*view in self.roundCornerView) {
        view.layer.cornerRadius = 5;
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 55) animated:YES];
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
        [self MTdismissKeyboard];
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
        [self.scrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - 100) animated:YES];
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
    [self.subject_text becomeFirstResponder];
    [self.subject_text resignFirstResponder];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int duration = 0;
    int status = 0;
    NSString *friends = @"[";
    BOOL flag = YES;
    for (NSNumber* friendid in self.FriendsIds) {
        friends = [friends stringByAppendingString: flag? @"%@":@",%@"];
        if (flag) flag = NO;
        friends = [NSString stringWithFormat:friends,friendid];
    }
    friends = [friends stringByAppendingString:@"]"];
    
    NSString* location = self.location_text.text;
    if ([location isEqualToString:@""]) location = @"未定";
    self.event_text.text = [self.event_text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.event_text.text isEqualToString: @""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"活动发布失败" WithMessage:@"活动名不能为空" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    
    NSString*beg_Time = self.begin_time_text.text;
    NSString*end_Time = self.end_time_text.text;
    if ([beg_Time isEqualToString:@""]) {
        if (![end_Time isEqualToString:@""]) {
            beg_Time = end_Time;
        }else{
            NSDateFormatter *formate = [[NSDateFormatter alloc]init];
            [formate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            beg_Time = [formate stringFromDate:[NSDate date]];
            end_Time = beg_Time;
        }
    } else if ([end_Time isEqualToString:@""]){
        end_Time = beg_Time;
    }else{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSDate* begin = [dateFormatter dateFromString:beg_Time];
        NSDate* end = [dateFormatter dateFromString:end_Time];
        NSTimeInterval begins = [begin timeIntervalSince1970];
        NSTimeInterval ends = [end timeIntervalSince1970];
        int dis = ends-begins;
        if (dis<0) {
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"结束时间必须大于开始时间" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }

    
    [self showWaitingView];
    [sender setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverButton) userInfo:nil repeats:NO];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.subject_text.text forKey:@"subject"];
    [dictionary setValue:beg_Time forKey:@"time"];
    [dictionary setValue:end_Time forKey:@"endTime"];
    [dictionary setValue:self.detail_text.text forKey:@"remark"];
    [dictionary setValue:location forKey:@"location"];
    [dictionary setValue:[NSNumber numberWithInt:duration] forKey:@"duration"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithInt:_visibility] forKey:@"visibility"];
    [dictionary setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    [dictionary setValue:[NSNumber numberWithInt:_code] forKeyPath:@"code"];
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
    self.positionInfo = @"";

    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
}

- (IBAction)getBanner:(id)sender {
    if (_isKeyBoard) {
        [self MTdismissKeyboard];
        return;
    }
    [self performSegueWithIdentifier:@"toBannerSelector" sender:self];
}

-(void) seletePosition
{
    [self performSegueWithIdentifier:@"map" sender:self];
    
}

#pragma mark - CollectionViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_InviteFriendsView.frame.size.height + _InviteFriendsView.frame.origin.y + 60 > _scrollView.contentSize.height) {
        CGSize size = _scrollView.contentSize;
        size.height = _InviteFriendsView.frame.size.height + _InviteFriendsView.frame.origin.y + 60;
        _scrollView.contentSize = size;
        
    }
}

#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _FriendsIds_array.count + 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"participantCell" forIndexPath:indexPath];
    [cell setHidden:NO];
    if(indexPath.row != _FriendsIds_array.count){
        //NSDictionary* participant = _participants[indexPath.row];
        UIImageView* avatar = (UIImageView*)[cell viewWithTag:1];
        if (!avatar) {
            avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 40, 40)];
            [avatar setTag:1];
            [cell addSubview:avatar];
        }
        [avatar setHighlightedImage:nil];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        if (!name) {
            name = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
            [name setTag:2];
            [name setFont:[UIFont systemFontOfSize:10]];
            [name setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:name];
        }
        avatar.layer.masksToBounds = YES;
        [avatar.layer setCornerRadius:5];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:_FriendsIds_array[indexPath.row] ];
        [getter getAvatar];
        //name.text = [MTUser sharedInstance].
        name.text = [[MTUser sharedInstance].nameFromID_dic valueForKey:[NSString stringWithFormat:@"%@",_FriendsIds_array[indexPath.row]]];
        
    }else{
        UIImageView* add = (UIImageView*)[cell viewWithTag:1];
        if (!add) {
            add = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 40, 40)];
            [add setTag:1];
            [cell addSubview:add];
        }
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        if (!name) {
            name = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
            [name setTag:2];
            [name setFont:[UIFont systemFontOfSize:10]];
            [name setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:name];
        }
        [add setHidden:NO];
        [add setImage:[UIImage imageNamed:@"grid_add_light"]];
        [add setHighlightedImage:[UIImage imageNamed:@"grid_add_pressed_light"]];
        name.text = @"";
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _FriendsIds.count) {
        [self performSegueWithIdentifier:@"LaunchToInvite" sender:self];
    }
}

#pragma mark - BMk Method
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
        NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString* bannerPath = [docFolder stringByAppendingPathComponent:@"tmp.jpg"];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:bannerPath])
            [fileManager removeItemAtPath:bannerPath error:nil];
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
        NSLog(@"初始化地理坐标为 %f  %f  ",self.pt.latitude,self.pt.longitude);
        nextViewController.position = self.pt;
        nextViewController.positionInfo = self.positionInfo;
        nextViewController.controller = self;
    }
    if ([segue.destinationViewController isKindOfClass:[BannerSelectorViewController class]]) {
        BannerSelectorViewController *nextViewController = segue.destinationViewController;
        nextViewController.controller = self;
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        [self removeWaitingView];
        ((HomeViewController*)self.controller).shouldRefresh = YES;
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
    _locService.delegate = nil;
    _locService = nil;
}
/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
-(void)didFailToLocateUserWithError:(NSError *)error
{
    [self.getLocIndicator stopAnimating];
    [self.getLocButton setHidden:NO];
    self.location_text.text = @"";
    [self.getLocButton setImage:[UIImage imageNamed:@"地图定位后icon"] forState:UIControlStateNormal];
    [self.getLocButton removeTarget:self action:@selector(getLoc:) forControlEvents:UIControlEventAllEvents];
    [self.getLocButton addTarget:self action:@selector(seletePosition) forControlEvents:UIControlEventTouchUpInside];
    [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"无法自动定位，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_locService stopUserLocationService];
        _locService.delegate = nil;
        _locService = nil;
    });
    
}

-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
}

#pragma mark - UIGestureRecognizer Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    

    if([touch.view.superview isKindOfClass:[UICollectionView class]]){
        return NO;
    }
    else
        
        return YES;
    
}


@end