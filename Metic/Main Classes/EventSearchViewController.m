 //
//  EventSearchViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-21.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventSearchViewController.h"
#import "nearbyEventTableViewCell.h"
#import "showParticipatorsViewController.h"
#import "CommonUtils.h"
#import "PhotoGetter.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "EventDetailViewController.h"
#import "EventPreviewViewController.h"
#import "SVProgressHUD.h"
#import "MegUtils.h"
#import "MTOperation.h"

@interface EventSearchViewController ()
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UISearchBar* searchBar;
@property(nonatomic,strong) NSMutableArray* eventIds;
@property(nonatomic,strong) NSMutableArray* events;
@property(nonatomic,strong) UIActivityIndicatorView* indicator;
@property(nonatomic,strong) MJRefreshFooterView* footer;
@property BOOL Footeropen;
@property BOOL isFirst;
@end

@implementation EventSearchViewController

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
    [self initData];
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"活动搜索"];
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width * 1/32;
    frame.origin.y = 44;
    frame.size.width = frame.size.width * 15/16;
    frame.size.height -= 44;
    [_tableView setFrame:frame];
    if (_isFirst) {
        _isFirst = NO;
        [_searchBar becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick beginLogPageView:@"活动搜索"];
}

-(void)dealloc
{
    [_footer free];
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

-(void)initData
{
    _isFirst = YES;
}

-(void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width * 1/32;
    frame.origin.y = 44;
    frame.size.width = frame.size.width * 15/16;
    frame.size.height -= 44;
    MTLOG(@"%f  %f",frame.origin.x,frame.size.width);
    _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0f]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setShowsVerticalScrollIndicator:NO];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    [self.view addSubview:_tableView];
    [self.view addSubview:_searchBar];
    [self.view setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0f]];
    //初始化上拉加载功能
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView;
}

-(void)search_eventIds
{
    NSString* text = self.searchBar.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.searchBar.text = @"";
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在搜索…" maskType:SVProgressHUDMaskTypeGradient];
    
    [self.searchBar resignFirstResponder];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:text forKey:@"subject"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    _eventIds = [response1 valueForKey:@"sequence"];
                    if (_events && _events.count > 0) {
                        [_events removeAllObjects];
                        [_tableView reloadData];
                    }
                    [self get_events];
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
        }
        
    }];

}

-(void)get_events
{
    int restNum = MIN(20, _eventIds.count - _events.count);
    if (restNum == 0){
        [SVProgressHUD dismiss];
        [self closeRJ];
        return;
    }
    NSArray* tmp = [_eventIds subarrayWithRange:NSMakeRange(_events.count, restNum)];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:tmp forKey:@"sequence"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            MTLOG(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"event_list"]];
                    for(int i = 0; i < tmp.count; i++)
                    {
                        NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc]initWithDictionary:tmp[i]];
                        tmp[i] = tmpDic;
                    }
                    if (!_events) {
                        _events = tmp;
                    }else{
                        [_events addObjectsFromArray:tmp];
                    }
                    
                    [SVProgressHUD dismiss];
                    [_tableView reloadData];
                    [self closeRJ];
                }
                    break;
                default:{
                    [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
                    [self closeRJ];
                }
                    break;
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常，请重试。"];
            [self closeRJ];
        }
    }];

}

-(void)showWaitingView
{
    if (!_indicator) {
        CGRect frame = self.tableView.bounds;
        frame.origin.x = (frame.size.width - 100)/2.0;
        frame.origin.y = (frame.size.height - 100)/2.0;
        frame.size = CGSizeMake(100, 100);
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:frame];
        [self.view addSubview:_indicator];
        [_indicator startAnimating];
        
    }
}

-(void)removeWaitingView
{
    if (_indicator) {
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
}

-(void)closeRJ
{
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
}


#pragma mark - UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [self search_eventIds];
}


#pragma UITableView Delegate & DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 258;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_events) return _events.count;
    else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTLOG(@"%d  %d",indexPath.row,_events.count);
    static NSString *CellIdentifier = @"nearbyEventCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([nearbyEventTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    nearbyEventTableViewCell *cell = (nearbyEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *a = _events[indexPath.row];
    cell.dict = a;
    cell.eventName.text = [a valueForKey:@"subject"];
    NSString* beginT = [a valueForKey:@"time"];
    NSString* endT = [a valueForKey:@"endTime"];
    cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
    cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
    cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
    cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
    
    
    NSInteger participator_count = [[a valueForKey:@"member_count"] integerValue];
    NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
    NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
    
    cell.member_count.font = [UIFont systemFontOfSize:15];
    cell.member_count.numberOfLines = 0;
    cell.member_count.lineBreakMode = NSLineBreakByCharWrapping;
    cell.member_count.tintColor = [UIColor lightGrayColor];
    [cell.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
        UIFont *systemFont = [UIFont systemFontOfSize:18];
        
        if (redRange.location != NSNotFound) {
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:redRange];
            
            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
            CFRelease(italicFont);
        }
        return mutableAttributedString;
    }];

    //显示备注名
    NSString* alias = [MTOperation getAliasWithUserId:a[@"launcher_id"] userName:a[@"launcher"]];
    cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",alias];
    cell.eventId = [a valueForKey:@"event_id"];
    cell.nearbyEventViewController = self;
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    [cell drawOfficialFlag:[[a valueForKey:@"verify"] boolValue]];
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
    NSString* bannerURL = [a valueForKey:@"banner"];
    NSString* bannerPath = [MegUtils bannerImagePathWithEventId:[a valueForKey:@"event_id"]];
    [bannerGetter getBanner:[a valueForKey:@"code"] url:bannerURL path:bannerPath];
    
    if ([[a valueForKey:@"isIn"] boolValue]) {
        [cell.statusLabel setHidden:NO];
        cell.statusLabel.text = @"已加入活动";
        [cell.wantInBtn setHidden:YES];
    }else if ([[a valueForKey:@"visibility"] boolValue]) {
        [cell.statusLabel setHidden:YES];
        [cell.wantInBtn setHidden:NO];
    }else{
        [cell.statusLabel setHidden:NO];
        cell.statusLabel.text = @"非公开活动";
        [cell.wantInBtn setHidden:YES];
    }
    
    NSArray *memberids = [a valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = cell.avatarArray[i];
        if (i < participator_count) {
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getAvatar];
        }else{
            [tmp sd_cancelCurrentImageLoad];
            tmp.image = nil;
        }
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nearbyEventTableViewCell* cell = (nearbyEventTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary* dict = cell.dict;
    
    if (![[dict valueForKey:@"isIn"] boolValue] && [[dict valueForKey:@"visibility"] integerValue] != 2) {
        EventPreviewViewController *viewcontroller = [[EventPreviewViewController alloc]init];
        viewcontroller.eventInfo = dict;
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }else{
        NSNumber* eventId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"event_id"]];
        NSNumber* eventLauncherId = [CommonUtils NSNumberWithNSString:[dict valueForKey:@"launcher_id"]];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        
        EventDetailViewController* eventDetailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
        eventDetailView.eventId = eventId;
        eventDetailView.eventLauncherId = eventLauncherId;
        eventDetailView.event = [dict mutableCopy];
        [self.navigationController pushViewController:eventDetailView animated:YES];
    }
    
    
}

#pragma mark - 跳转前数据准备 Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[showParticipatorsViewController class]]) {
        showParticipatorsViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = _selectedEventId;
        nextViewController.canManage = NO;
    }
}


#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_Footeropen) {
        return;
    }
    _Footeropen = YES;
    [self get_events];
}

@end
