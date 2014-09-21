 //
//  EventSearchViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-21.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventSearchViewController.h"
#import "../Cell/nearbyEventTableViewCell.h"
#import "showParticipatorsViewController.h"
#import "../Utils/CommonUtils.h"
#import "PhotoGetter.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"

@interface EventSearchViewController ()
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UISearchBar* searchBar;
@property(nonatomic,strong) NSMutableArray* eventIds;
@property(nonatomic,strong) NSMutableArray* events;
@property(nonatomic,strong) UIActivityIndicatorView* indicator;
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    _isFirst = YES;
}

-(void)initUI
{
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width * 1/32;
    frame.origin.y = 44;
    frame.size.width = frame.size.width * 15/16;
    frame.size.height -= 44;
    NSLog(@"%f  %f",frame.origin.x,frame.size.width);
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
}

-(void)search_eventIds
{
    NSString* text = self.searchBar.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.searchBar.text = @"";
        return;
    }
    [self.searchBar resignFirstResponder];
    [self showWaitingView];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:text forKey:@"subject"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SEARCH_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
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
                    [self removeWaitingView];
                    [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:nil WithCancelTitle:@"确定"];
                }
                    break;
            }
        }else{
            [self removeWaitingView];
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:nil WithCancelTitle:@"确定"];
        }
        
    }];

}

-(void)get_events
{
    int restNum = MIN(20, _eventIds.count - _events.count);
    if (restNum == 0){
        [self removeWaitingView];
        //[self closeRJ];
        return;
    }
    NSArray* tmp = [_eventIds subarrayWithRange:NSMakeRange(_events.count, restNum)];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:tmp forKey:@"sequence"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
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
                    
                    [self removeWaitingView];
                    [_tableView reloadData];
                }
                    break;
                default:{
                    [self removeWaitingView];
                    [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:nil WithCancelTitle:@"确定"];
                    //[alert setTag:102];
                }
                    break;
            }
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:nil WithCancelTitle:@"确定"];
            //[alert setTag:102];
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
    static NSString *CellIdentifier = @"nearbyEventCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([nearbyEventTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    nearbyEventTableViewCell *cell = (nearbyEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *a = _events[indexPath.row];
    cell.eventName.text = [a valueForKey:@"subject"];
    NSString* beginT = [a valueForKey:@"time"];
    NSString* endT = [a valueForKey:@"endTime"];
    cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
    cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
    cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[a valueForKey:@"launch_time"]];
    cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
    int participator_count = [[a valueForKey:@"member_count"] intValue];
    cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
    cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
    cell.eventId = [a valueForKey:@"event_id"];
    cell.nearbyEventViewController = self;
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
    [bannerGetter getBanner:[a valueForKey:@"code"]];
    
    if ([[a valueForKey:@"visibility"] boolValue]) {
        [cell.statusLabel setHidden:YES];
        [cell.wantInBtn setHidden:NO];
    }else{
        [cell.statusLabel setHidden:NO];
        [cell.wantInBtn setHidden:YES];
    }
    
    NSArray *memberids = [a valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
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
    NSLog(@"a");
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
@end
