
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
#import "SVProgressHUD.h"
#import "MTOperation.h"
#import "SingleSelectionAlertView.h"

static NSString * const defaultDetail = @"输入活动描述，让其他人更好了解您的活动内容";

@interface LaunchEventViewController () <SingleSelectionAlertViewDelegate>
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) UITextField *seletedTextField;
@property (nonatomic, strong) NSString *seletedText;
@property (nonatomic, strong) NSMutableSet *FriendsIds;
@property (nonatomic, strong) NSMutableArray *FriendsIds_array;
@property (nonatomic, strong) NSDictionary* positions;
@property (nonatomic, strong) NSDictionary* locationInfo;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *getLocIndicator;
@property (nonatomic, strong) IBOutlet UIButton *getLocButton;
@property (nonatomic, strong) BMKGeoCodeSearch* geocodesearch;
@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic, strong) SingleSelectionAlertView *typeSelectView;
//@property (nonatomic, strong) BMKMapManager *mapManager;
@property (nonatomic, strong) UIView* waitingView;
@property (nonatomic, strong) FlatDatePicker *flatDatePicker;
@property (nonatomic) NSInteger visibility;
@property BOOL isKeyBoard;
@property (nonatomic, strong) UIView* InviteFriendsView;

@property (strong,nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) CLLocationManager  *locationManager;
@property (nonatomic, strong) NSArray* notFriendsList;
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
    [self setupUI];
    [self setupData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //_locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _geocodesearch.delegate = self;
    if (![self.positionInfo isEqualToString:@""]) {
        self.location_text.text = self.positionInfo;
    }
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
    MTLOG(@"delete");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//返回上一层
-(void)MTpopViewController{
    if ([self shouldDraft]) {
        [self alertMakingDraft];
    }else [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setupUI
- (void)setupUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self drawLeftButton];
    [self turnRoundCorner];
    
    self.detail_text.text = defaultDetail;
    self.detail_text.textColor = [UIColor lightGrayColor];
}

- (void)drawLeftButton{
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 71, 33)];
    [leftButton setImage:[UIImage imageNamed:@"头部左上角图标-返回"] forState:UIControlStateNormal];
    [leftButton setTitle:@"        " forState:UIControlStateNormal];
    [leftButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [leftButton addTarget:self action:@selector(MTpopViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}

-(void)turnRoundCorner
{
    for (int i = 0; i < self.roundCornerView.count; i++) {
        UIView* view = [self.roundCornerView objectAtIndex:i];
        view.layer.cornerRadius = 5;
    }
}

#pragma mark - setupData
- (void)setupData
{
    self.scrollView.delegate = self;
    self.begin_time_text.delegate = self;
    self.end_time_text.delegate = self;
    self.event_text.delegate = self;
    self.location_text.delegate = self;
    self.detail_text.delegate = self;
    
    [self initInviteFriendsView];
    _code = -1;
    _canLeave = NO;
    _isKeyBoard = NO;
    _visibility = 2;
    _canLeave = NO;
    self.FriendsIds = [[NSMutableSet alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    self.pt = (CLLocationCoordinate2D){999.999999, 999.999999};
    self.positionInfo = @"";
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MTdismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [self loadDraft];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.subject_text];
}

-(void)MTdismissKeyboard
{
    if (![_scrollView isUserInteractionEnabled] || !self.isKeyBoard) {
        return;
    }
    [_subject_text becomeFirstResponder];
    [_subject_text resignFirstResponder];
}

- (BOOL)shouldDraft
{
    if (![_subject_text.text isEqualToString:@""]) {
        return YES;
    }
    
    if (![_begin_time_text.text isEqualToString:@""]) {
        return YES;
    }
    
    if (![_end_time_text.text isEqualToString:@""]) {
        return YES;
    }
    
    if (![_location_text.text isEqualToString:@""] && ![_location_text.text isEqualToString:@"定位中"]) {
        return YES;
    }
    
    if (![_detail_text.text isEqualToString:@""] && ![_detail_text.text isEqualToString:defaultDetail]) {
        return YES;
    }
    
    return NO;
    
}
- (void)alertMakingDraft{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否保存草稿" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag = 120;
    [alert show];
}

- (void)loadDraft{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* LaunchDf = [userDf objectForKey:[NSString stringWithFormat:@"LAUNCH%@",[MTUser sharedInstance].userid]];
    if (LaunchDf) {
        _subject_text.text = [LaunchDf valueForKey:@"subject_text"];
        _begin_time_text.text = [LaunchDf valueForKey:@"begin_time_text"];
        _end_time_text.text = [LaunchDf valueForKey:@"end_time_text"];
        _location_text.text = [LaunchDf valueForKey:@"location_text"];
        _detail_text.text = [LaunchDf valueForKey:@"detail_text"];
        _pt.longitude = [[LaunchDf valueForKey:@"longitude"] doubleValue];
        _pt.latitude = [[LaunchDf valueForKey:@"latitude"] doubleValue];
        
        [userDf removeObjectForKey:[NSString stringWithFormat:@"LAUNCH%@",[MTUser sharedInstance].userid]];
        [userDf synchronize];
    }
}

- (void)makeDraft{
    //取
//    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",uid]];
    
    //存
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* LaunchDf = [[NSMutableDictionary alloc]init];
    [LaunchDf setValue:_subject_text.text forKey:@"subject_text"];
    [LaunchDf setValue:_begin_time_text.text forKey:@"begin_time_text"];
    [LaunchDf setValue:_end_time_text.text forKey:@"end_time_text"];
    [LaunchDf setValue:_location_text.text forKey:@"location_text"];
    [LaunchDf setValue:_detail_text.text forKey:@"detail_text"];
    [LaunchDf setValue:[NSNumber numberWithDouble:_pt.longitude] forKey:@"longitude"];
    [LaunchDf setValue:[NSNumber numberWithDouble:_pt.latitude] forKey:@"latitude"];
    
    [userDf setObject:LaunchDf forKey:[NSString stringWithFormat:@"LAUNCH%@",[MTUser sharedInstance].userid]];
    [userDf synchronize];
}

-(void)initInviteFriendsView
{
    _InviteFriendsView = [[UIView alloc]initWithFrame:CGRectMake(20, 625, 280, 70)];
    [_InviteFriendsView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    _InviteFriendsView.layer.cornerRadius = 5;
    [_scrollView addSubview:_InviteFriendsView];
    
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
    
    if (CGRectGetMaxY(self.InviteFriendsView.frame) + 15 != _scrollView.contentSize.height) {
        CGSize size = _scrollView.contentSize;
        size.height = CGRectGetMaxY(self.InviteFriendsView.frame) + 15;
        _scrollView.contentSize = size;
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
        [_launch_button setEnabled:NO];
        self.flatDatePicker.delegate = self;
        self.flatDatePicker.title = @"请选择活动日期";
        NSDate *date;
        if (![textField.text isEqualToString:@""]) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            MTLOG(@"#%@#",textField.text);
            date= [dateFormatter dateFromString:textField.text];
        }else date = [NSDate date];
        self.seletedTextField = textField;
        self.seletedText = textField.text;
        [self.flatDatePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:15768000000]];
        self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;
        [self.flatDatePicker setDate:date animated:NO];
        [self.flatDatePicker show];
        return NO;
        
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - 100) animated:YES];
        return YES;
    }
}

-(void)textFieldEditChanged:(NSNotification*)obj
{
    NSInteger kMaxLength = 45;
    UITextField* textField = (UITextField*)obj.object;
    NSString* toBeString = textField.text;
    //获取当前输入法
    NSString* lang = [[UITextInputMode currentInputMode] primaryLanguage];
    //    MTLOG(@"当前输入法： %@", lang);
    if ([lang isEqualToString:@"zh-Hans"]) { //当前输入法是中文
        UITextRange* selectedRange = [textField markedTextRange]; //高亮的文本范围
        UITextPosition* position = [textField positionFromPosition:selectedRange.start offset:0];
        
        if (!position) { //不存在高亮的文本
            if (toBeString.length > kMaxLength) { //超过了最大长度限制
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
            
            else{
                
            }
        }
    }
    else{ //非中文输入法
        
        if (toBeString.length > kMaxLength) { //超过了最大长度
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
        
    }
}

- (void)closeDatePicker
{
    NSDate *curDate = [self.datePicker date];
    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *formateDateString = [formate stringFromDate:curDate];
    MTLOG(@"%@",formateDateString);
    self.seletedTextField.enabled = YES;
    self.seletedTextField.text = formateDateString;
    
    [_datePickerView removeFromSuperview ];
}

- (void)checkTimeValid
{
    if ([self.begin_time_text.text isEqualToString:@""] || [self.end_time_text.text isEqualToString:@""]) {
        return;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSDate* begin = [dateFormatter dateFromString:self.begin_time_text.text];
    NSDate* end = [dateFormatter dateFromString:self.end_time_text.text];
    NSTimeInterval begins = [begin timeIntervalSince1970];
    NSTimeInterval ends = [end timeIntervalSince1970];
    int dis = ends-begins;
    if (dis<0) {
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"结束时间必须大于开始时间" WithDelegate:nil WithCancelTitle:@"确定"];
        self.end_time_text.text = @"";
    }
    
}

- (void)setVisibility:(NSInteger)visibility
{
    _visibility = visibility;
    NSArray *arr = @[@"公开（内容公开）", @"公开（内容不公开）",@"私人"];
    if (visibility >= 0 && visibility < arr.count) {
        NSString *title = arr[2-visibility];
        [self.eventTypeMenuView setTitle:title forState:UIControlStateNormal];
    }
}

- (IBAction)changeEventType:(id)sender {
    [self.subject_text becomeFirstResponder];
    [self.subject_text resignFirstResponder];
    NSArray *arr = @[@"公开活动（内容公开）", @"公开活动（内容不公开）",@"私人"];
    NSInteger index = 2 - _visibility;
    self.typeSelectView = [[SingleSelectionAlertView alloc]initWithContentSize:CGSizeMake(300, 400) withTitle:@"修改活动类型" withOptions:arr];
    self.typeSelectView.kDelegate = self;
    self.typeSelectView.tag = 0;
    [self.typeSelectView selectItemAtIndex:index];
    [self.typeSelectView show];
}

- (IBAction)launch:(id)sender {
    [self.subject_text becomeFirstResponder];
    [self.subject_text resignFirstResponder];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int duration = 0;
    int status = 0;
    NSString *friends = [CommonUtils arrayStyleStringfromNummerArray:self.FriendsIds];
    
    _notFriendsList = nil;
    NSString* location = self.location_text.text;
    if ([location isEqualToString:@""] || [location isEqualToString:@"定位中"]) location = @"地点未定";
    self.event_text.text = [self.event_text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.event_text.text isEqualToString: @""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"活动发布失败" WithMessage:@"活动名不能为空" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    
    NSString*beg_Time = ([self.begin_time_text.text isEqualToString:@""])? self.begin_time_text.text:[self.begin_time_text.text stringByAppendingString:@":00"];
    NSString*end_Time = ([self.end_time_text.text isEqualToString:@""])? self.end_time_text.text:[self.end_time_text.text stringByAppendingString:@":00"];
    
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
    
    NSString *remark = self.detail_text.text;
    if (!remark || [remark isEqualToString:defaultDetail]) {
        remark = @"";
    }
    
    [SVProgressHUD showWithStatus:@"正在发布..." maskType:SVProgressHUDMaskTypeGradient];
    [sender setEnabled:NO];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.subject_text.text forKey:@"subject"];
    [dictionary setValue:beg_Time forKey:@"time"];
    [dictionary setValue:end_Time forKey:@"endTime"];
    [dictionary setValue:remark forKey:@"remark"];
    [dictionary setValue:location forKey:@"location"];
    [dictionary setValue:[NSNumber numberWithInt:duration] forKey:@"duration"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.longitude] forKey:@"longitude"];
    [dictionary setValue:[NSNumber numberWithDouble:_pt.latitude] forKey:@"latitude"];
    [dictionary setValue:[NSNumber numberWithInteger:_visibility] forKey:@"visibility"];
    [dictionary setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    [dictionary setValue:(_code == -1? @(random()%6+2):@(_code)) forKeyPath:@"code"];
    [dictionary setValue:friends forKey:@"friends"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:LAUNCH_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"Received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            NSNumber *tmpid = [response1 valueForKey:@"event_id"];
            NSArray* notFriendsList = [response1 valueForKey:@"list"];
            _notFriendsList = notFriendsList;
            if ([cmd intValue] != SERVER_ERROR && [tmpid intValue] != -1) {
                if (self.uploadImage) {
                    PhotoGetter *getter = [[PhotoGetter alloc]initUploadMethod:self.uploadImage type:1];
                    getter.mDelegate = self;
                    [getter uploadBanner:[response1 valueForKey:@"event_id"]];
                }else{
                    [SVProgressHUD dismissWithSuccess:@"活动发布成功" afterDelay:1];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        ((HomeViewController*)self.controller).shouldRefresh = YES;
                        self.canLeave = YES;
                        [self.navigationController popViewControllerAnimated:YES];
                        [[MTOperation sharedInstance]inviteFriends:notFriendsList];
                    });
                }
            }else{
                [SVProgressHUD dismissWithError:@"活动发布失败" afterDelay:1];
                [sender setEnabled:YES];
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试" afterDelay:1];
            [sender setEnabled:YES];
        }
        
    }];
    
}

- (IBAction)getLoc:(id)sender {
    [self.getLocButton setHidden:YES];
    [self.getLocIndicator startAnimating];
    self.location_text.text = @"定位中";
    self.pt = (CLLocationCoordinate2D){23.114155, 113.318977};
    self.positionInfo = @"";

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8 && self.locationManager == nil) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        _locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
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

#pragma mark - UITextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:defaultDetail]) {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1) {
        textView.textColor = [UIColor grayColor];
        textView.text = defaultDetail;
    }
}
#pragma mark - ScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (CGRectGetMaxY(self.InviteFriendsView.frame) + 15 != _scrollView.contentSize.height) {
        CGSize size = _scrollView.contentSize;
        size.height = CGRectGetMaxY(self.InviteFriendsView.frame) + 15 ;
        _scrollView.contentSize = size;
    }
    [self MTdismissKeyboard];
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
        //显示备注名
        NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",_FriendsIds_array[indexPath.row]]];
        if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
            alias = [[MTUser sharedInstance].nameFromID_dic valueForKey:[NSString stringWithFormat:@"%@",_FriendsIds_array[indexPath.row]]];
        }
        name.text = alias;
        
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

#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *value = [dateFormatter stringFromDate:date];
        self.seletedTextField.text = value;
    } else{
        if ([self.seletedTextField.text isEqualToString:@""]) {
            return;
        }
        [dateFormatter setDateFormat:@" HH:mm"];
        NSString *value = [dateFormatter stringFromDate:date];
        value = [[self.seletedTextField.text substringToIndex:10] stringByAppendingString:value];
        self.seletedTextField.text = value;
    }
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    datePicker.delegate = nil;
    self.seletedTextField.text = self.seletedText;
    [_launch_button setEnabled:YES];
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
        [_launch_button setEnabled:YES];
        [self.scrollView setUserInteractionEnabled:YES];
        datePicker.delegate = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkTimeValid];
        });
        return;
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
        [SVProgressHUD dismissWithSuccess:@"活动发布成功" afterDelay:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ((HomeViewController*)self.controller).shouldRefresh = YES;
            self.canLeave = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [[MTOperation sharedInstance]inviteFriends:_notFriendsList];
        });
    }else if (type == 106){
        [SVProgressHUD dismissWithSuccess:@"活动发布成功，封面上传失败" afterDelay:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ((HomeViewController*)self.controller).shouldRefresh = YES;
            self.canLeave = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [[MTOperation sharedInstance]inviteFriends:_notFriendsList];
        });
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
        MTLOG(@"初始化地理坐标为 %f  %f  ",self.pt.latitude,self.pt.longitude);
        nextViewController.position = self.pt;
        nextViewController.positionInfo = self.positionInfo;
        nextViewController.controller = self;
    }
    if ([segue.destinationViewController isKindOfClass:[BannerSelectorViewController class]]) {
        BannerSelectorViewController *nextViewController = segue.destinationViewController;
        nextViewController.code = _code;
        nextViewController.Lcontroller = self;
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if ([alertView tag] == 120) {
        if (buttonIndex == 1)
        {
            [self makeDraft];
        }
        self.canLeave = YES;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (buttonIndex == 0)
    {
        [self removeWaitingView];
        ((HomeViewController*)self.controller).shouldRefresh = YES;
        self.canLeave = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{

    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        MTLOG(@"反geo检索发送成功");
    } else {
        [self.getLocIndicator stopAnimating];
        [self.getLocButton setImage:[UIImage imageNamed:@"地图定位后icon"] forState:UIControlStateNormal];
        [self.getLocButton removeTarget:self action:@selector(getLoc:) forControlEvents:UIControlEventAllEvents];
        [self.getLocButton addTarget:self action:@selector(seletePosition) forControlEvents:UIControlEventTouchUpInside];
        [self.getLocButton setHidden:NO];
        MTLOG(@"反geo检索发送失败");
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

    if([touch.view.superview isKindOfClass:[UICollectionViewCell class]]){
        return NO;
    }
    else return YES;
    
}

#pragma mark - SingleSelectionAlertView Delegate
- (void)SingleSelectionAlertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[CustomIOS7AlertView class]]) {
        if (((CustomIOS7AlertView*)alertView).tag == 0) {
            if (buttonIndex == 1) {
                NSInteger type = [self.typeSelectView getSelectedIndex];
                self.visibility = 2 - type;
            }
        }
    } else if ([alertView isKindOfClass:[UIButton class]]) {
        
    }
}
@end