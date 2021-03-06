
//
//  EventDetailViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event2DcodeViewController.h"
#import "EventEditViewController.h"
#import "BannerSelectorViewController.h"
#import "HomeViewController.h"
#import "EventCellTableViewCell.h"
#import "MTUser.h"
#import "PictureWall2.h"
#import "VideoWallViewController.h"
#import "Report/ReportViewController.h"
#import "MCommentTableViewCell.h"
#import "SCommentTableViewCell.h"
#import "EventCellTableViewCell.h"
#import "showParticipatorsViewController.h"
#import "MLEmojiLabel.h"
#import "NSString+JSON.h"
#import "emotion_Keyboard.h"
#import "MobClick.h"
#import "KxMenu.h"
#import "SVProgressHUD.h"
#import "NotificationController.h"
#import "MTDatabaseHelper.h"
#import "MTDatabaseAffairs.h"
#import "MTOperation.h"
#import "MegUtils.h"
#import "SocialSnsApi.h"
//#import "ScanViewController.h"

#define MainFontSize 14
#define MainCFontSize 13
#define SubCFontSize 12

@interface EventDetailViewController ()<MTTextInputViewDelegate, UMSocialUIDelegate, UITextViewDelegate>
@property(nonatomic,strong) NSMutableArray *comment_list;
@property(nonatomic,strong) UIAlertView *Alert;
@property(nonatomic,strong) NSNumber* repliedId;
@property(nonatomic,strong) emotion_Keyboard *emotionKeyboard;
@property(nonatomic,strong) NSString* herName;
@property(nonatomic,strong) UIView* shadowView;
@property(nonatomic,strong) IBOutlet UIButton *likeBtn;
@property(nonatomic,strong) IBOutlet UIButton *shareBtn;
@property(nonatomic,strong) NSString *eventShareLink;
@property(nonatomic,weak) UIImageView *themeImageView;

@property BOOL visibility;
@property BOOL isMine;
@property long mainCommentId;
@property long Selete_section;
@property BOOL Headeropen;
@property BOOL Footeropen;

//@property(nonatomic) int cellcount;

@end

@implementation EventDetailViewController
{
    NSMutableDictionary *dicClicked;
    CGFloat mHeight;
    NSInteger sectionIndex;
    //int main_Comment_count = 0;
}


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
    [self initUI];
    [self fixStack];
    [self initData];
    [CommonUtils addLeftButton:self isFirstPage:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_shadowView) [_shadowView removeFromSuperview];
    [_tableView reloadData];
    [self pullEventFromAir];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textInputView addKeyboardObserver];
    [MobClick beginLogPageView:@"活动详情"];
    if (_Bannercode>-1) {
        [SVProgressHUD showWithStatus:@"正在更改封面" maskType:SVProgressHUDMaskTypeClear];
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            MTLOG(@"没有网络");
            _Bannercode = -1;
            _uploadImage = nil;
            [SVProgressHUD dismissWithError:@"网络无连接，更改封面失败" afterDelay:1];
            return;
        }
        if (_Bannercode > 0 && _eventId) {
            
            //上报封面修改信息
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_eventId forKey:@"event_id"];
            [dictionary setValue:[NSNumber numberWithInteger:_Bannercode] forKey:@"code"];
            _Bannercode = -1;
            [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:SET_EVENT_BANNER finshedBlock:^(NSData *rData) {
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    MTLOG(@"%@",response1);
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == NORMAL_REPLY) {
                        [self pullEventFromAir];
                        
                        [SVProgressHUD dismissWithSuccess:@"更改封面成功" afterDelay:1];
                    }else{
                        [SVProgressHUD dismissWithError:@"网络异常，更改封面失败"];
                    }
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常，更改封面失败"];
                }
            }];
            
        }else if (_Bannercode == 0){
            PhotoGetter *getter = [[PhotoGetter alloc]initUploadMethod:self.uploadImage type:1];
            getter.mDelegate = self;
            [getter uploadBanner:_eventId];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textInputView dismissKeyboard];
    [self.textInputView removeKeyboardObserver];
    [KxMenu dismissMenu];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动详情"];
    [self.textInputView dismissKeyboard];
}

- (void)dealloc
{
    [_header free];
    [_footer free];
}

-(void)initUI
{
    float var = 242/255.0;
    [_tableView setBackgroundColor:[UIColor colorWithRed:var green:var blue:var alpha:1]];
    self.view.autoresizesSubviews = YES;
    [self setupBottomView];
    [self setupLikeState];
    [self setupShareBtn];
}

-(void)initData
{
    [NotificationController visitEvent:_eventId];
    self.comment_list = [[NSMutableArray alloc]init];
    self.Bannercode = -1;
    self.mainCommentId = 0;
    self.Headeropen = NO;
    self.Footeropen = NO;
    self.master_sequence = [NSNumber numberWithInt:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.textInputView.placeHolder = @"回复楼主";
    
    [self.view bringSubviewToFront:self.emotionKeyboard];
    [self pullEventFromDB];
    [self pullMainCommentFromAir];
    
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView;
    
    [self visitEvent];
}

-(void)fixStack
{
    if (!_isFromQRCode) return;
    NSInteger vccount = self.navigationController.viewControllers.count;
    if (vccount > 1) {
        NSMutableArray* newVCs = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
        UIViewController* home = ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController;
        if (home) {
            newVCs[1] = home;
            for (NSInteger i = vccount - 2; i > 1; i --) {
                [newVCs removeObjectAtIndex:i];
            }
            self.navigationController.viewControllers = newVCs;
        }
    }
}

-(void)setupBottomView
{
    if (_event) {
        if ([[_event valueForKey:@"isIn"] boolValue] ) {
            [self setupCommentView];
        }else if ([[_event valueForKey:@"visibility"] integerValue] == 2){
            [self setupApplyTextView];
        }
    }
}

-(void)setupCommentView
{
    if (self.textInputView && self.textInputView.style == MTInputSytleApply) {
        [self.textInputView removeKeyboardObserver];
        [self.textInputView removeFromSuperview];
        self.textInputView = nil;
    }else if(self.textInputView && self.textInputView.style == MTInputSytleComment){
        return;
    }
    
    self.textInputView = [[MTTextInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 45, kMainScreenWidth, 45) style:MTInputSytleComment];
    self.textInputView.delegate = self;
    self.textInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.textInputView];
}

-(void)setupApplyTextView
{
    if (self.textInputView && self.textInputView.style == MTInputSytleComment) {
        [self.textInputView removeKeyboardObserver];
        [self.textInputView removeFromSuperview];
        self.textInputView = nil;
    }else if(self.textInputView && self.textInputView.style == MTInputSytleApply){
        return;
    }
    
    self.textInputView = [[MTTextInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 45, kMainScreenWidth, 45) style:MTInputSytleApply];
    self.textInputView.delegate = self;
    self.textInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.textInputView];
    
}

-(void)showMenu
{
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];
    if (_event) {
        if (_eventId && [_eventId intValue]!=0 && [[_event valueForKey:@"isIn"]boolValue]) {
            [menuItems addObjectsFromArray:@[
                                             
                                             [KxMenuItem menuItem:@"查看二维码"
                                                            image:nil
                                                           target:self
                                                           action:@selector(show2Dcode:)],
                                             ]];
        }
        
        if (_eventId && [_eventId intValue]!=0) {
            BOOL islike = [[self.event valueForKey:@"islike"] boolValue];
            [menuItems addObjectsFromArray:@[
                                             
                                             [KxMenuItem menuItem:islike? @"取消收藏":@"收藏活动"
                                                            image:nil
                                                           target:self
                                                           action:@selector(like:)],
                                             ]];
        }
        if (_eventId && [_eventId intValue]!=0 && [[_event valueForKey:@"launcher_id"] intValue] != [[MTUser sharedInstance].userid intValue]) {
            [menuItems addObjectsFromArray:@[
                                             
                                             [KxMenuItem menuItem:@"举报活动"
                                                            image:nil
                                                           target:self
                                                           action:@selector(report:)],
                                             ]];
        }
        if ([[_event valueForKey:@"launcher_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
            [menuItems addObjectsFromArray:@[
                                             [KxMenuItem menuItem:@"编辑活动"
                                                            image:nil
                                                           target:self
                                                           action:@selector(editEvent)],
                                             
                                             [KxMenuItem menuItem:@"解散活动"
                                                            image:nil
                                                           target:self
                                                           action:@selector(dismissEvent)],
                                             ]];
        }else if([[_event valueForKey:@"isIn"]boolValue]){
            [menuItems addObjectsFromArray:@[
                                             
                                             [KxMenuItem menuItem:@"退出活动"
                                                            image:nil
                                                           target:self
                                                           action:@selector(quitEvent)]]];
        }
    }
    
    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width*0.9, 60, 0, 0)
                 menuItems:menuItems];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)visitEvent
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:VIEW_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            MTLOG(@"%@",cmd);
        }
    }
     ];
}

- (void)pullMainCommentFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    long sequence = [self.master_sequence longValue];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:0] forKey:@"master"];
    [dictionary setValue:self.master_sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    if ([self.master_sequence isEqualToNumber:@0])
        [dictionary setValue:@(YES) forKey:@"all"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    static NSInteger operationNum = 0;
    operationNum ++;
    NSInteger operNum = operationNum;
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_COMMENTS finshedBlock:^(NSData *rData) {
        if (operNum != operationNum) return ;
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    if ([response1 valueForKey:@"comment_list"]) {
                        int type = [[response1 valueForKey:@"type"]intValue];
                        NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"comment_list"]];
                        for (int i = 0; i < tmp.count; i++) {
                            tmp[i] = [[NSMutableArray alloc] initWithArray:tmp[i]];
                            for (int j = 0; j < ((NSMutableArray*)tmp[i]).count; j++) {
                                tmp[i][j] = [[NSMutableDictionary alloc]initWithDictionary:tmp[i][j]];
                            }
                        }
                        if (type == 0) {
                            if (sequence == [_master_sequence longValue]) {
                                self.master_sequence = [response1 valueForKey:@"sequence"];
                                if (sequence == 0) [_comment_list removeAllObjects];
                                [self.comment_list addObjectsFromArray:tmp];
                                [_tableView reloadData];
                                if (_Footeropen && [_master_sequence intValue] == -1) {
                                    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
                                    [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
                                }else if (_Footeropen || _Headeropen) {
                                    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
                                }else [_tableView reloadData];
                            }
                        }
                    }
                    
                }
                    break;
            }
        }
    }];
}

-(void)getmoreComments:(NSNumber*) master sub_Sequence:(NSNumber*)sub_Sequence Scomments:(NSMutableArray*)Scomments
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:master forKey:@"master"];
    [dictionary setValue:sub_Sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_COMMENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                NSMutableArray *comments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"comment_list"]];
                for (int i = 0; i < comments.count; i++) {
                    NSMutableDictionary* comment = [[NSMutableDictionary alloc]initWithDictionary:comments[i]];
                    comments[i] = comment;
                }
                [Scomments addObjectsFromArray:comments];
                [_tableView reloadData];
            }else{
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            }
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        }
        
    }];
}


- (void)pullEventFromDB
{
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance]queryTable:@"event" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count) {
            NSString *tmpa = [resultsArray[0] valueForKey:@"event_info"];
            NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
            self.event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
            if ([_event valueForKey:@"launcher_id"]) _eventLauncherId = [_event valueForKey:@"launcher_id"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setupBottomView];
                [self setupLikeState];
            });
            
        }
    }];
    
}

-(void)pullEventFromAir
{
    NSArray* eventids = @[_eventId];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            //            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            //            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    if (((NSArray*)[response1 valueForKey:@"event_list"]).count > 0) {
                        NSDictionary* dict = [response1 valueForKey:@"event_list"][0];
                        
                        if (![[dict valueForKey:@"isIn"] boolValue] && [[dict valueForKey:@"visibility"] integerValue] != 2) {
                            [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"你不在此活动中" WithDelegate:self WithCancelTitle:@"确定"];
                            [self removeEventFromDB];
                            [self deleteItemfromHomeArray];
                            [NotificationController clearEventInfo:_eventId];
                            return ;
                        }
                        
                        if (_event) {
                            NSString* bannerURL = [dict valueForKey:@"banner"];
                            NSString* updatetime = [dict valueForKey:@"updatetime"];
                            [self checkBanner:updatetime bannerURL:bannerURL];
                        }
                        if ([_event valueForKey:@"event_id"]) _eventId = [_event valueForKey:@"event_id"];
                        if ([_event valueForKey:@"launcher_id"]) _eventLauncherId = [_event valueForKey:@"launcher_id"];
                        
                        [self replaceItemfromArray:_event newArr:dict];
                        [_tableView endUpdates];
                        self.event = dict;
                        [_tableView reloadData];
                        [self setupBottomView];
                        [self setupLikeState];
                        if(_event && [[dict valueForKey:@"isIn"] boolValue]) [[MTDatabaseAffairs sharedInstance] saveEventToDB:_event];
                    }else{
                        [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"此活动已经解散" WithDelegate:self WithCancelTitle:@"确定"];
                        [self removeEventFromDB];
                        [self deleteItemfromHomeArray];
                        [NotificationController clearEventInfo:_eventId];
                    }
                }
                    break;
                default:
                    break;
            }
            
            
            
        }
        
    }];
}

- (void)removeEventFromDB
{
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"event" withWhere:wheres];
}

- (void)updateUpdateTimeToDB:(NSString*)updateTime
{
    NSDictionary* wheres = [CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",_eventId],@"event_id",nil];
    NSDictionary* sets = [CommonUtils packParamsInDictionary:
                          [NSString stringWithFormat:@"'%@'",updateTime],@"updateTime",
                          nil];
    
    [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"event" andWhere:wheres andSet:sets];
}

- (void)checkBanner:(NSString*) updateTime bannerURL:(NSString*)bannerURL
{
    if (!updateTime || !bannerURL) {
        return;
    }
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"updateTime", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance]queryTable:@"event" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        if (resultsArray.count) {
            NSString *oldUpdateTime = [resultsArray[0] valueForKey:@"updateTime"];
            if ([oldUpdateTime isKindOfClass:[NSString class]] && [oldUpdateTime isEqualToString:updateTime]) {
                MTLOG(@"no need update banner");
            }else if ([oldUpdateTime isEqual:[NSNull null]]){
                [self updateUpdateTimeToDB:updateTime];
            }else {
                MTLOG(@"update banner");
                NSString* bannerPath = [MegUtils bannerImagePathWithEventId:_eventId];
                [[SDImageCache sharedImageCache] removeImageForKey:bannerPath];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
                [self updateUpdateTimeToDB:updateTime];
            }
        }
    }];
    
}

-(void)deleteItemfromHomeArray
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_eventId,@"eventId", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil userInfo:dict];
}

-(void)replaceItemfromArray:(NSDictionary*)oldArr newArr:(NSDictionary*)newArr
{
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_eventId,@"eventId", newArr,@"eventInfo",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"replaceItem" object:nil userInfo:dict];
    return;
    
    int index = self.navigationController.viewControllers.count - 2;
    HomeViewController* controller = (HomeViewController*)self.navigationController.viewControllers[index];
    
    if ([controller isKindOfClass:[HomeViewController class]]) {
        [controller.events replaceObjectAtIndex:[controller.events indexOfObject:oldArr] withObject:newArr];
        [controller.tableView reloadData];
    }
}

- (IBAction)more:(id)sender {
    [self showMenu];
}

- (void)setupShareBtn {
    self.shareBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)setupLikeState
{
    //    if (_event) {
    //        if (![[_event valueForKey:@"isIn"] boolValue]) {
    //            _likeBtn.hidden = YES;
    //            return;
    //        }else{
    //            _likeBtn.hidden = NO;
    //        }
    //        BOOL islike = [[_event valueForKey:@"islike"] boolValue];
    //        if (islike) {
    //            [_likeBtn setImage:[UIImage imageNamed:@"favored"] forState:UIControlStateNormal];
    //        }else{
    //            [_likeBtn setImage:[UIImage imageNamed:@"favor"] forState:UIControlStateNormal];
    //        }
    //    }else {
    //        _likeBtn.hidden = YES;
    //    }
}

- (IBAction)share:(id)sender {
    [self.textInputView dismissKeyboard];
    void (^share)(NSString *shareLink) = ^(NSString *shareLink){
        NSString *user = [MTUser sharedInstance].name;
        if (!user || ![user isKindOfClass:[NSString class]]) {
            user = @"";
        } else {
            user =  [NSString stringWithFormat:@"【%@】", user];
        }
        NSString *shareText = [NSString stringWithFormat:@"%@分享了活动宝的一个活动给你，点击查看", user];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareLink;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareLink;
        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"【活动宝分享】";
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.url = shareLink;
        [UMSocialData defaultData].extConfig.qqData.title = @"【活动宝分享】";
        [[UMSocialData defaultData].extConfig.sinaData setUrlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeVideo url:shareLink]];
        [UMSocialData defaultData].extConfig.smsData.urlResource = nil;
        [UMSocialData defaultData].extConfig.smsData.shareText = [NSString stringWithFormat:@"%@ %@",shareText,shareLink];
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];
        
        NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
        if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
            [shareToSns addObject:UMShareToSms];
        }
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:shareText
                                         shareImage:self.themeImageView.image?self.themeImageView.image:[UIImage imageNamed:@"AppIcon57x57"]
                                    shareToSnsNames:shareToSns
                                           delegate:self];
    };
    
    if ([self.eventShareLink isKindOfClass:[NSString class]] && ![self.eventShareLink isEqualToString:@""]) {
        share(self.eventShareLink);
    } else {
        [SVProgressHUD showWithStatus:@"请稍候" maskType:SVProgressHUDMaskTypeBlack];
        [[MTOperation sharedInstance] getEventShareLinkEventId:self.eventId success:^(NSString *shareLink) {
            self.eventShareLink = shareLink;
            [SVProgressHUD dismiss];
            share(shareLink);
        } failure:^(NSString *message) {
            [SVProgressHUD dismissWithError:message afterDelay:1.5f];
        }];
    }
}

- (IBAction)like:(id)sender {
    if(_eventId && _event) {
        __weak UIButton* likeBtn = self.likeBtn;
        __weak NSMutableDictionary* eventInfo = _event;
        
        NSNumber* eventId = [_eventId copy];
        
        likeBtn.enabled = NO;
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]initWithDictionary:_event];
        BOOL islike = [[dict valueForKey:@"islike"] boolValue];
        [[MTOperation sharedInstance] likeEventOperation:@[_eventId] like:!islike finishBlock:^(BOOL isSuccess, NSString *likeTime){
            if (isSuccess) {
                [dict setValue:@(!islike) forKey:@"islike"];
                if(likeTime)[dict setValue:likeTime forKey:@"likeTime"];
                [[MTDatabaseAffairs sharedInstance] saveEventToDB:dict];
                
                if (islike) {
                    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:eventId,@"eventId", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteLikeItem" object:nil userInfo:dict];
                }
                
                if (eventInfo) {
                    [eventInfo setValue:@(!islike) forKey:@"islike"];
                }
                
                if (likeBtn) {
                    likeBtn.enabled = YES;
                    if (isSuccess) {
                        if (islike) {
                            [likeBtn setImage:[UIImage imageNamed:@"favor"] forState:UIControlStateNormal];
                        }else{
                            [likeBtn setImage:[UIImage imageNamed:@"favored"] forState:UIControlStateNormal];
                        }
                        
                    }
                }
            }
        }];
    }
}

- (void)delete_Comment:(id)sender {
    self.textInputView.text = @"";
    self.textInputView.placeHolder = @"回复楼主:";
    self.repliedId = nil;
    self.mainCommentId = 0;
    [self.textInputView clear];
    
    id cell = sender;
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSInteger section = [_tableView indexPathForCell:cell].section;
    NSMutableArray *comments = _comment_list[section-1];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:((MCommentTableViewCell*)cell).commentid forKey:@"comment_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:DELETE_COMMENT finshedBlock:^(NSData *rData) {
        if (!rData) {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
        
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                [_comment_list removeObject:comments];
                [_tableView reloadData];
                
            }
                break;
            case SERVER_ERROR:
            {
                
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"评论删除失败" WithDelegate:nil WithCancelTitle:@"确定"];
                
            }
                break;
            default:{
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
            }
        }
    }];
}

- (void)appreciate:(id)sender {
    if(![[_event valueForKey:@"isIn"]boolValue]) return;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSInteger section = [_tableView indexPathForCell:cell].section;
    NSMutableArray *comments = _comment_list[section-1];
    NSMutableDictionary *waitingComment = _comment_list[section-1][0];
    BOOL isZan = [[waitingComment valueForKey:@"isZan"] boolValue];
    
    //点赞 或取消点缀操作
    [[MTOperation sharedInstance] likeOperationWithType:MTMediaTypeComment mediaId:((MCommentTableViewCell*)cell).commentid eventId:self.eventId like:!isZan finishBlock:NULL];
    
    [waitingComment setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
    int zan_num = [[waitingComment valueForKey:@"good"] intValue];
    if (isZan) {
        zan_num --;
    }else{
        zan_num ++;
    }
    [waitingComment setValue:[NSNumber numberWithInt:zan_num] forKey:@"good"];
    [_tableView reloadData];
}


-(void)resendComment:(id)sender{
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSMutableDictionary *waitingComment;
    NSMutableArray *comments = _comment_list[section-1];
    if (row == 0) {
        waitingComment = _comment_list[section-1][0];
    }else{
        waitingComment = _comment_list[section-1][[_comment_list[section-1] count] - row];
    }
    NSString *comment = [waitingComment valueForKey:@"content"];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"comment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[waitingComment valueForKey:@"master"] forKey:@"master"];
    if ([waitingComment valueForKey:@"replied"]) {
        [dictionary setValue:[waitingComment valueForKey:@"replied"] forKey:@"replied"];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    void (^resendCommentBlock)(void) = ^(void){
        //再次发送评论
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_COMMENT finshedBlock:^(NSData *rData) {
            if (rData) {
                NSString* content = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                MTLOG(@"%@",content);
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"comment_id"]) {
                    [waitingComment setValue:[response1 valueForKey:@"comment_id"] forKey:@"comment_id"];
                    [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
                }
            }else{
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            }
            
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                NSInteger nRow = row == 0? 0 : comments.count - [comments indexOfObject:waitingComment];;
                NSInteger nSection = [_comment_list indexOfObject:comments] + 1;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nRow inSection:nSection];
                NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                if ([visibleIndexPath containsObject:indexPath]) {
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }];
    };
    
    //检查token
    if([waitingComment valueForKey:@"token"]){
        [dictionary setValue:[waitingComment valueForKey:@"token"] forKey:@"token"];
        resendCommentBlock();
    }else{
        //获取token
        NSMutableDictionary *token_dict = [[NSMutableDictionary alloc] init];
        //    [token_dict setValue:[MTUser sharedInstance].userid forKey:@"id"];
        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:token_dict options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender1 = [[HttpSender alloc]initWithDelegate:self];
        [httpSender1 sendMessage:jsonData1 withOperationCode:TOKEN finshedBlock:^(NSData *rData) {
            if (rData) {
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                    NSString* token = [response1 valueForKey:@"token"];
                    @synchronized(self)
                    {
                        if (![waitingComment valueForKey:@"token"]) {
                            [waitingComment setValue:token forKey:@"token"];
                        }
                    }
                    [dictionary setValue:[waitingComment valueForKey:@"token"] forKey:@"token"];
                    resendCommentBlock();
                    return ;
                }else{
                    [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
                }
            }else{
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            }
            
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                NSInteger nRow = row == 0? 0 : comments.count - [comments indexOfObject:waitingComment];;
                NSInteger nSection = [_comment_list indexOfObject:comments] + 1;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nRow inSection:nSection];
                NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                if ([visibleIndexPath containsObject:indexPath]) {
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }];
    }
}

- (IBAction)publishComment:(id)sender {
    NSString *comment = self.textInputView.text;
    
    [self.textInputView clear];
    
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return;
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[NSNumber numberWithLong:self.mainCommentId] forKey:@"master"];
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    if (_repliedId && [_repliedId intValue]!=[[MTUser sharedInstance].userid intValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_herName forKey:@"replier"];
        //comment = [[NSString stringWithFormat:@" 回复 %@ : ",_herName] stringByAppendingString:comment];
    }
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"comment_num"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"comment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:[NSNumber numberWithLong:self.mainCommentId] forKey:@"master"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];
    NSMutableArray*newComments;
    long commentType = _mainCommentId;
    NSInteger row = 0;
    NSInteger section = 0;
    
    switch (commentType) {
        case 0:{
            
            //加入到评论数组里
            newComments = [[NSMutableArray alloc] initWithObjects:newComment, nil];
            [_comment_list insertObject:newComments atIndex:0];
            row = 0;
            section = 1;
            
        }
            break;
            
        default:{
            newComments = _comment_list[_Selete_section-1];
            [newComments insertObject:newComment atIndex:1];
            row = newComments.count - 1;
            section = _Selete_section;
        }
            break;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    @synchronized(self) {
        [_tableView beginUpdates];
        if (commentType == 0) {
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationLeft];
        }else {
            [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [_tableView endUpdates];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
    
    [self.textInputView clear];
    
    void (^sendCommentBlock)(void) = ^(void){
        //发送评论
        MTLOG(@"%@",dictionary);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:ADD_COMMENT finshedBlock:^(NSData *rData) {
            if (rData) {
                NSString* content = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                MTLOG(@"%@",content);
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"comment_id"]) {
                    [newComment setValue:[response1 valueForKey:@"comment_id"] forKey:@"comment_id"];
                    [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                }else{
                    [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
                }
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            }
            
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                NSInteger row = commentType == 0? 0 : newComments.count - [newComments indexOfObject:newComment];
                NSInteger section = [_comment_list indexOfObject:newComments] + 1;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
                if ([visibleIndexPath containsObject:indexPath]) {
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            });
        }];
    };
    
    //获取token
    NSMutableDictionary *token_dict = [[NSMutableDictionary alloc] init];
    //    [token_dict setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:token_dict options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender1 = [[HttpSender alloc]initWithDelegate:self];
    [httpSender1 sendMessage:jsonData1 withOperationCode:TOKEN finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* content = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"%@",content);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"token"]) {
                NSString* token = [response1 valueForKey:@"token"];
                @synchronized(self)
                {
                    if (![newComment valueForKey:@"token"]) {
                        [newComment setValue:token forKey:@"token"];
                    }
                }
                [dictionary setValue:[newComment valueForKey:@"token"] forKey:@"token"];
                sendCommentBlock();
                return ;
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
        }
        
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            NSInteger row = commentType == 0? 0 : newComments.count - [newComments indexOfObject:newComment];
            NSInteger section = [_comment_list indexOfObject:newComments] + 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NSArray *visibleIndexPath = self.tableView.indexPathsForVisibleRows;
            if ([visibleIndexPath containsObject:indexPath]) {
                [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }];
}

- (IBAction)publish100Comment:(id)sender {
    for(int i = 0; i < 100; i++) {
        [self publishComment:nil];
    }
    [self.tableView reloadData];
}


- (void)show2Dcode:(id)sender {
    
    [self performSegueWithIdentifier:@"2Dcode" sender:self];
}

- (void)report:(id)sender {
    
    [self performSegueWithIdentifier:@"EventToReport" sender:self];
    
}

- (void)editEvent
{
    if (_event) {
        EventEditViewController* eventEditVc = [[EventEditViewController alloc]init];
        eventEditVc.eventId = _eventId;
        eventEditVc.eventInfo = _event;
        [self.navigationController pushViewController:eventEditVc animated:YES];
    }
}

-(void)setupBottomLabel:(NSString*)content textColor:(UIColor*)color offset:(NSInteger)offset
{
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 50, CGRectGetWidth(self.view.bounds), 50)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.text = content;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor colorWithWhite:252.0/255.0 alpha:1.0];
    label.layer.borderColor = [UIColor colorWithWhite:220.0/255.0 alpha:1.0].CGColor;
    label.layer.borderWidth = 1;
}

-(void)apply:(id)sender
{
    if (sender) {
        [sender setEnabled:NO];
    }
    NSString* confirmMsg = self.textInputView.text;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:REQUEST_EVENT] forKey:@"cmd"];
    [dictionary setValue:confirmMsg forKey:@"confirm_msg"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    if (self.shareId) {
        [dictionary setValue:self.shareId forKey:@"share_id"];
    }
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        [sender setEnabled:YES];
        if (!rData) {
            return ;
        }
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                [self.textInputView clear];
                [self setupBottomLabel:@"已申请加入" textColor:[UIColor colorWithRed:85.0/255 green:203.0/255 blue:171.0/255 alpha:1.0f] offset:0];
                
            }
                break;
        }
    }];
}


-(void)changeBanner
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    BannerSelectorViewController * BanSelector = [mainStoryboard instantiateViewControllerWithIdentifier: @"BannerSelectorViewController"];
    BanSelector.code = [[_event valueForKey:@"code"] integerValue];
    BanSelector.Econtroller = self;
    [self.navigationController pushViewController:BanSelector animated:YES];
}

-(void)quitEvent
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出此活动 ？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:130];
    [alert show];
}

-(void)dismissEvent
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要解散此活动 ？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:140];
    [alert show];
}


-(void)closeRJ
{
    if (_Headeropen) {
        _Headeropen = NO;
        [_header endRefreshing];
    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
    [self.tableView reloadData];
}

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.Footeropen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:YES];
}

-(NSNumber *)eventLauncherId
{
    if (_eventLauncherId) {
        return _eventLauncherId;
    }else if (_event){
        NSNumber* eventLauncherId = [_event valueForKey:@"launcher_id"];
        if (eventLauncherId) _eventLauncherId = eventLauncherId;
        return eventLauncherId;
    }else{
        return nil;
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        MTLOG(@"没有网络");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
        });
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    if (_Footeropen||_Headeropen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshView endRefreshing];
        });
        return;
    }
    if (refreshView == _header) {
        _Headeropen = YES;
        self.master_sequence = [NSNumber numberWithInt:0];
        [self pullEventFromAir];
    }else _Footeropen = YES;
    [self pullMainCommentFromAir];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.comment_list.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    NSMutableArray *comments = self.comment_list[section - 1];
    NSDictionary *mainCom = comments[0];
    int comment_num = [[mainCom valueForKey:@"comment_num"] intValue];
    if (comment_num > comments.count - 1) {
        return comments.count+1;
    }
    
    return comments.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.textInputView dismissKeyboard]) {
        return;
    }
    
    if (![[_event valueForKey:@"isIn"] boolValue] && [[_event valueForKey:@"visibility"] integerValue] == 2) {
        return;
    }
    
    if (indexPath.section == 0) {
        [self.textInputView openKeyboard];
        self.textInputView.placeHolder = @"回复楼主:";
        self.repliedId = nil;
        self.mainCommentId = 0;
    } else if (indexPath.row == 0) {
        MCommentTableViewCell *cell = (MCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.commentid intValue] < 0 ) {
            [self resendComment: cell.resend_Button];
            return;
        }
        [self.textInputView openKeyboard];
        self.textInputView.placeHolder = [NSString stringWithFormat:@"回复%@:",cell.author];
        self.mainCommentId = [cell.commentid longValue];
        self.Selete_section = indexPath.section;
        self.repliedId = nil;
    } else {
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            NSDictionary* lastSubComment = [comments lastObject];
            [self getmoreComments:[lastSubComment valueForKey:@"master"] sub_Sequence:[lastSubComment valueForKey:@"comment_id"]Scomments:comments];
            return;
        }
        SCommentTableViewCell *cell = (SCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.commentid intValue] < 0 ) {
            [self resendComment: cell.resend_Button];
            return;
        }
        [self.textInputView openKeyboard];
        self.textInputView.placeHolder = [NSString stringWithFormat:@"回复%@:",cell.author];
        self.mainCommentId = [cell.mainCommentId longValue];
        self.repliedId = cell.authorid;
        self.Selete_section = indexPath.section;
        self.herName = cell.author;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mCellIdentifier = @"McommentCell";
    static NSString *sCellIdentifier = @"ScommentCell";
    
    
    if (indexPath.section == 0) {
        
        NSString* cellClassName = @"EventCellTableViewCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:cellClassName bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellClassName];
            nibsRegistered = YES;
        }
        
        MTTableViewCellBase *cell = (MTTableViewCellBase *)[tableView dequeueReusableCellWithIdentifier:cellClassName];
        cell.controller = self;
        self.themeImageView = ((EventCellTableViewCell *)cell).themePhoto;
        if (self.event) {
            [cell applyData:_event];
        }
        
        _isMine = [[_event valueForKey:@"launcher_id"] intValue] == [[MTUser sharedInstance].userid intValue];
        _visibility = [[_event valueForKey:@"isIn"] boolValue] && ([[_event valueForKey:@"visibility"] boolValue] || _isMine);
        
        
        return cell;
    }
    else if (indexPath.row == 0) {
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([MCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:mCellIdentifier];
            nibsRegistered = YES;
        }
        MCommentTableViewCell *cell = (MCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:mCellIdentifier];
        NSDictionary *mainCom = self.comment_list[indexPath.section - 1][0];
        
        //显示备注名
        NSString* author = [MTOperation getAliasWithUserId:mainCom[@"author_id"] userName:mainCom[@"author"]];
        cell.publisher.text = author;
        cell.publishTime.text = mainCom[@"time"];
        if([[mainCom valueForKey:@"comment_num"]intValue]==0) [cell.subCommentBG setHidden:YES];
        else [cell.subCommentBG setHidden:NO];
        
        
        MLEmojiLabel *textView = cell.comment;
        NSString* text = [mainCom valueForKey:@"content"];
        cell.origincomment = text;
        NSString*alias1,*alias2;
        
        if ([[mainCom valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias1 = [MTOperation getAliasWithUserId:mainCom[@"author_id"] userName:mainCom[@"author"]];
            alias2 = [MTOperation getAliasWithUserId:mainCom[@"replied"] userName:mainCom[@"replier"]];
            
            text = [NSString stringWithFormat:@"%@ 回复%@ : %@",alias1,alias2,text];
        }
        
        [textView setDisableThreeCommon:YES];
        textView.numberOfLines = 0;
        textView.font = [UIFont systemFontOfSize:MainCFontSize];
        textView.backgroundColor = [UIColor clearColor];
        textView.lineBreakMode = NSLineBreakByCharWrapping;
        textView.isNeedAtAndPoundSign = YES;
        textView.emojiText = text;
        
        cell.commentid = [mainCom valueForKey:@"comment_id"];
        cell.eventId = _eventId;
        cell.author = author;
        cell.authorId = [mainCom valueForKey:@"author_id"];
        cell.controller = self;
        cell.good_num.text = [NSString stringWithFormat:@"(%d)",[[mainCom valueForKey:@"good"]intValue]];
        cell.isZan = [[mainCom valueForKey:@"isZan"] boolValue];
        if (cell.isZan) {
            [cell.good_button setImage:[UIImage imageNamed:@"实心点赞图"] forState:UIControlStateNormal];
        }else [cell.good_button setImage:[UIImage imageNamed:@"点赞图"] forState:UIControlStateNormal];
        if ([[mainCom valueForKey:@"comment_id"] intValue] == -1 ) {
            [cell.zanView setHidden:YES];
            [cell.waitView startAnimating];
            [cell.resend_Button setHidden:YES];
            
            
        }else if([[mainCom valueForKey:@"comment_id"] intValue] == -2){
            [cell.zanView setHidden:YES];
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:NO];
            [cell.resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [cell.waitView stopAnimating];
            [cell.zanView setHidden:NO];
            [cell.resend_Button setHidden:YES];
        }
        
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[mainCom valueForKey:@"author_id"]];
        [avatarGetter getAvatar];
        
        return cell;
    } else {
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 30)];
            [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:242/255.0]];
            UIView *content = [[UIView alloc]initWithFrame:CGRectMake(10, 0, kMainScreenWidth - 20, 30)];
            [content setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
            [cell addSubview:content];
            
            UIView* shadow = [cell viewWithTag:100];
            [shadow setBackgroundColor:[CommonUtils colorWithValue:0xe7e7e7]];
            
            UILabel* more = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth / 2 - 60, 0, 100, 30)];
            [more setBackgroundColor:[UIColor clearColor]];
            [more setText:@"查看更多评论"];
            [more setTextAlignment:NSTextAlignmentCenter];
            [more setFont:[UIFont systemFontOfSize:12]];
            [content addSubview:more];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([SCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:sCellIdentifier];
            nibsRegistered = YES;
        }
        SCommentTableViewCell *cell = (SCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
        NSDictionary *subCom = self.comment_list[indexPath.section - 1][[self.comment_list[indexPath.section - 1] count] - indexPath.row];
        NSDictionary *mainCom = self.comment_list[indexPath.section - 1][0];
        cell.McommentArr = self.comment_list[indexPath.section - 1];
        cell.ScommentDict = subCom;
        //显示备注名
        NSString* author = [MTOperation getAliasWithUserId:subCom[@"author_id"] userName:subCom[@"author"]];
        NSString* text = [subCom valueForKey:@"content"];
        NSString* alias1,*alias2;
        if ([[subCom valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias1 = [MTOperation getAliasWithUserId:subCom[@"author_id"] userName:subCom[@"author"]];
            alias2 = [MTOperation getAliasWithUserId:subCom[@"replied"] userName:subCom[@"replier"]];
            
            text = [NSString stringWithFormat:@"%@ 回复%@ : %@",alias1,alias2,text];
        }else{
            alias1 = [MTOperation getAliasWithUserId:subCom[@"author_id"] userName:subCom[@"author"]];
            text = [NSString stringWithFormat:@"%@: %@",alias1,text];
        }
        cell.originComment = [subCom valueForKey:@"content"];
        NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
        [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,alias1.length)];
        cell.comment.author1Length = alias1.length;
        cell.comment.author2Length = alias2.length;
        cell.comment.font = [UIFont systemFontOfSize:SubCFontSize];
        [cell.comment setNumberOfLines:0];
        [cell.comment setLineBreakMode:NSLineBreakByCharWrapping];
        cell.comment.emojiText = text;
        //[((MLEmojiLabel*)cell.comment) setText:hintString1];
        
        if ([[subCom valueForKey:@"comment_id"] intValue] == -1 ) {
            [cell.waitView startAnimating];
            [cell.resend_Button setHidden:YES];
            [cell.publishTimeLabel setHidden:YES];
        }else if([[subCom valueForKey:@"comment_id"] intValue] == -2){
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:NO];
            [cell.publishTimeLabel setHidden:YES];
            [cell.resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:YES];
            [cell.publishTimeLabel setHidden:NO];
        }
        
        UIView* shadow = [cell viewWithTag:100];
        [shadow setBackgroundColor:[CommonUtils colorWithValue:0xe7e7e7]];
        
        cell.commentid = [subCom valueForKey:@"comment_id"];
        cell.mainCommentId = [mainCom valueForKey:@"comment_id"];
        cell.authorid = [subCom valueForKey:@"author_id"];
        cell.author = author;
        cell.controller = self;
        cell.publishTimeLabel.text = [CommonUtils calculateTimeStr:subCom[@"time"] shortVersion:YES];
        
        return cell;
    }
    
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section !=  0 && indexPath.row != 0)
    {
        SCommentTableViewCell* cell = (SCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        UIView* shadow = [cell viewWithTag:100];
        [shadow setBackgroundColor:[CommonUtils colorWithValue:0xe0e0e0]];
    }
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section !=  0 && indexPath.row != 0)
    {
        SCommentTableViewCell* cell = (SCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        UIView* shadow = [cell viewWithTag:100];
        [shadow setBackgroundColor:[CommonUtils colorWithValue:0xe7e7e7]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString* text = [_event valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:kMainScreenWidth - 20 fontSize:MainFontSize isEmotion:NO];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
        }else if(text) commentHeight += 5;
        return 128.0 + commentHeight + 158 * kMainScreenWidth / 320 + 31 * (kMainScreenWidth - 30) / 290.0f;
    } else if (indexPath.row == 0) {
        NSDictionary *mainCom = self.comment_list[indexPath.section - 1][0];
        NSString* text = [mainCom valueForKey:@"content"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:290.0 *  (kMainScreenWidth - 30) / 290.0f fontSize:MainCFontSize isEmotion:YES];
        if (commentHeight < 25.0f) commentHeight = 25.0f;
        return 65.0f + commentHeight;
        
    } else {
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            return 30;
        }
        NSDictionary *subCom = self.comment_list[indexPath.section - 1][ [self.comment_list[indexPath.section - 1] count] - indexPath.row];
        NSString* text = [subCom valueForKey:@"content"];
        NSString* alias1,*alias2;
        if ([[subCom valueForKey:@"replied"] intValue] != 0) {
            //显示备注名
            alias1 = [MTOperation getAliasWithUserId:subCom[@"author_id"] userName:subCom[@"author"]];
            alias2 = [MTOperation getAliasWithUserId:subCom[@"replied"] userName:subCom[@"replier"]];
            text = [NSString stringWithFormat:@"%@ 回复%@ : %@",alias1,alias2,text];
        }else{
            alias1 = [MTOperation getAliasWithUserId:subCom[@"author_id"] userName:subCom[@"author"]];
            text = [NSString stringWithFormat:@"%@: %@",alias1,text];
        }
        float commentHeight = [CommonUtils calculateTextHeight:text width:kMainScreenWidth - 70.0 fontSize:SubCFontSize isEmotion:YES] + 0.5f;
        if (commentHeight < 25.5f) commentHeight = 25.5f;
        return commentHeight;
    }
}


#pragma mark - TextField view delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textInputView dismissKeyboard];
}


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[EventDetailViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[PictureWall2 class]]) {
            PictureWall2 *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = [self.event valueForKey:@"subject"];
            nextViewController.eventLauncherId = self.eventLauncherId;
        }
        if ([segue.destinationViewController isKindOfClass:[VideoWallViewController class]]) {
            VideoWallViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = [self.event valueForKey:@"subject"];
            nextViewController.eventLauncherId = self.eventLauncherId;
        }
        if ([segue.destinationViewController isKindOfClass:[showParticipatorsViewController class]]) {
            showParticipatorsViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.canManage = _visibility;
            nextViewController.isMine = _isMine;
            nextViewController.visibility = _visibility;
        }
        if ([segue.destinationViewController isKindOfClass:[Event2DcodeViewController class]]) {
            Event2DcodeViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.eventInfo = _event;
        }
        if ([segue.destinationViewController isKindOfClass:[ReportViewController class]]) {
            ReportViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.event = [self.event valueForKey:@"subject"];
            nextViewController.type = 1;
        }
    }
}

#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 130) {
        if (buttonIndex == 1) {
            //退出活动
            [SVProgressHUD showWithStatus:@"正在退出活动" maskType:SVProgressHUDMaskTypeClear];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_eventId forKey:@"event_id"];
            [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
            MTLOG(@"%@",dictionary);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:QUIT_EVENT finshedBlock:^(NSData *rData) {
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == QUIT_EVENT_SUC) {
                        [self removeEventFromDB];
                        [self deleteItemfromHomeArray];
                        
                        [SVProgressHUD dismissWithSuccess:@"退出活动成功" afterDelay:0.2];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        
                    }else{
                        [SVProgressHUD dismissWithError:@"网络异常，操作失败"];
                    }
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常，操作失败"];
                }
            }];
        }
        
        return;
    }else if([alertView tag] == 140){
        if(buttonIndex == 1){
            //解散活动
            [SVProgressHUD showWithStatus:@"正在解散活动" maskType:SVProgressHUDMaskTypeClear];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_eventId forKey:@"event_id"];
            [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
            MTLOG(@"%@",dictionary);
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:QUIT_EVENT finshedBlock:^(NSData *rData) {
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == QUIT_EVENT_SUC) {
                        [self removeEventFromDB];
                        [self deleteItemfromHomeArray];
                        
                        [SVProgressHUD dismissWithSuccess:@"解散活动成功" afterDelay:0.2];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        
                    }else{
                        [SVProgressHUD dismissWithError:@"网络异常，操作失败"];
                    }
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常，操作失败"];
                }
            }];
        }
        return;
    }
    
    
    switch (buttonIndex) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    if (type == 100){
        //上传封面后 删除临时文件
        NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString* bannerTmpPath = [docFolder stringByAppendingPathComponent:@"tmp.jpg"];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:bannerTmpPath])
            [fileManager removeItemAtPath:bannerTmpPath error:nil];
        NSString* bannerPath = [MegUtils bannerImagePathWithEventId:_eventId];
        [[SDImageCache sharedImageCache] removeImageForKey:bannerPath];
        
        //上报封面修改信息
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:_eventId forKey:@"event_id"];
        [dictionary setValue:[NSNumber numberWithInt:_Bannercode] forKey:@"code"];
        _Bannercode = -1;
        [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
        MTLOG(@"%@",dictionary);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:SET_EVENT_BANNER finshedBlock:^(NSData *rData) {
            if (rData) {
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY) {
                    [self pullEventFromAir];
                    [SVProgressHUD dismissWithSuccess:@"更改封面成功" afterDelay:1];
                }else{
                    [SVProgressHUD dismissWithError:@"网络异常，更改封面失败"];
                }
            }else{
                [SVProgressHUD dismissWithError:@"网络异常，更改封面失败"];
            }
        }];
        
    }else if (type == 106){
        [SVProgressHUD dismissWithError:@"网络异常，更改封面失败"];
    }
}

#pragma mark - MTTextInputView delegate
- (void)textInputView:(MTTextInputView *)textInputView sendMessage:(NSString *)message {
    if (textInputView.style == MTInputSytleComment) {
        [self publishComment:nil];
    } else if (textInputView.style == MTInputSytleApply) {
        [self apply:nil];
    }
}

@end