//
//  EventEditViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditViewController.h"
#import "PhotoGetter.h"
#import "CommonUtils.h"
#import "Reachability.h"
#import "MTDatabaseAffairs.h"

#import "EventEditSubjectViewController.h"
#import "EventEditTimeViewController.h"
#import "EventEditLocationViewController.h"
#import "EventEditRemarkViewController.h"
#import "BannerSelectorViewController.h"
#import "EventEditTypeViewController.h"

#import "SVProgressHUD.h"

const float rowHeight = 42.0f;
//1.1.1版本不需要修改活动类型
const NSInteger rowCount = 3;

@interface EventEditViewController () <UITableViewDataSource,UITableViewDelegate,PhotoGetterDelegate>
@property (nonatomic,strong) UIImageView* banner;
@property (nonatomic,strong) UITableView* tableView;

@end

@implementation EventEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkBannerChange];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

-(void)dealloc
{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"编辑活动";
    
    UIView* bannerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 126)];
    [self.view addSubview:bannerView];
    
    _banner = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 123)];
    _banner.userInteractionEnabled = YES;
    [_banner setContentMode:UIViewContentModeScaleAspectFill];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBanner)];
    tapRecognizer.numberOfTapsRequired=1;
    [_banner addGestureRecognizer:tapRecognizer];
    [bannerView addSubview:_banner];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:_banner authorId:self.eventId];
    NSString* bannerURL = [_eventInfo valueForKey:@"banner"];
    [bannerGetter getBanner:[_eventInfo valueForKey:@"code"] url:bannerURL];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 123, CGRectGetWidth(self.view.frame), 3)];
    [line setBackgroundColor:[UIColor orangeColor]];
    [bannerView addSubview:line];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 126, CGRectGetWidth(self.view.frame) - 20, 300)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;

}

-(void)initData
{
    self.Bannercode = -1;
}

- (void)refresh
{
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:_banner authorId:self.eventId];
    NSString* bannerURL = [_eventInfo valueForKey:@"banner"];
    [bannerGetter getBanner:[_eventInfo valueForKey:@"code"] url:bannerURL retainOldone:YES];
    [_tableView reloadData];
}

-(void)checkBannerChange
{
    if (_Bannercode>-1) {
        if(_Bannercode >= 2 && _Bannercode == [[_eventInfo valueForKey:@"code"]integerValue])return;
        [SVProgressHUD showWithStatus:@"正在更改封面" maskType:SVProgressHUDMaskTypeClear];
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
            NSLog(@"没有网络");
            _Bannercode = -1;
            _uploadImage = nil;
            [SVProgressHUD dismissWithError:@"网络无连接，更改封面失败" afterDelay:1];
            return;
        }
        if (_Bannercode > 0 && _eventId) {
            NSInteger bannercode = _Bannercode;
            //上报封面修改信息
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_eventId forKey:@"event_id"];
            [dictionary setValue:[NSNumber numberWithInteger:bannercode] forKey:@"code"];
            _Bannercode = -1;
            [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:SET_EVENT_BANNER finshedBlock:^(NSData *rData) {
                if (rData) {
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSLog(@"%@",response1);
                    NSNumber *cmd = [response1 valueForKey:@"cmd"];
                    if ([cmd intValue] == NORMAL_REPLY) {
                        [_eventInfo setValue:@(bannercode) forKey:@"code"];
                        [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                        [self refresh];
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
            _uploadImage = nil;
            getter.mDelegate = self;
            [getter uploadBanner:_eventId];
        }
        
    }
}

-(void)changeBanner
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    BannerSelectorViewController * BanSelector = [mainStoryboard instantiateViewControllerWithIdentifier: @"BannerSelectorViewController"];
    BanSelector.code = [[_eventInfo valueForKey:@"code"] integerValue];
    BanSelector.EEcontroller = self;
    [self.navigationController pushViewController:BanSelector animated:YES];
}

#pragma UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return rowCount;
            break;
            
        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return rowHeight;
            break;
        case 1:
        {
            if (indexPath.row > 0 && indexPath.row < rowCount - 1) {
                return rowHeight + 2;
            }else{
                return rowHeight + 1;
            }
        }
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc]init];
    cell.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.clipsToBounds = YES;
        cell.layer.cornerRadius = 6;
        cell.layer.masksToBounds = YES;
    }else if (indexPath.row == 0){
        UIView* background = [[UIView alloc]initWithFrame:CGRectMake(0, 12*2 + 42, CGRectGetWidth(_tableView.frame), rowHeight*rowCount + 2*rowCount-2)];
        background.backgroundColor = [UIColor whiteColor];
        [_tableView addSubview:background];
        [_tableView sendSubviewToBack:background];
        background.layer.cornerRadius = 6;
        background.layer.masksToBounds = YES;
    }
    
    if (indexPath.row > 0) {
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1)];
        [line setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [cell addSubview:line];
    }
    
    if (indexPath.row < rowCount - 1) {
        float y = rowHeight + 1;
        if (indexPath.row == 0) {
            y = rowHeight;
        }
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.frame), 1)];
        [line setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [cell addSubview:line];
    }
    
    UILabel* title = [[UILabel alloc]init];
    title.textAlignment = NSTextAlignmentLeft;
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    CGRect titleframe = CGRectMake(10, 0, 60, 0);
    
    [cell addSubview:title];
    
    UILabel* content = [[UILabel alloc]init];
    content.textAlignment = NSTextAlignmentRight;
    content.font = [UIFont systemFontOfSize:15];
    content.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
    CGRect contentframe = CGRectMake(80, 0, 190, 0);
    
    [cell addSubview:content];
    
    
    
    switch (indexPath.section) {
        case 0:
        {
            titleframe.size.height = rowHeight;
            contentframe.size.height = rowHeight;
            title.text = @"活动主题";
            content.text = [_eventInfo valueForKey:@"subject"];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    titleframe.size.height = rowHeight + 1;
                    contentframe.size.height = rowHeight + 1;
                    title.text = @"活动时间";
//                    content.text = [_eventInfo valueForKey:@"launch_time"];
                    break;
                case 1:
                    titleframe.size.height = rowHeight + 2;
                    contentframe.size.height = rowHeight + 2;
                    title.text = @"活动地点";
//                    content.text = [_eventInfo valueForKey:@"location"];
                    break;
                case 2:
                    titleframe.size.height = rowHeight + 1;
                    contentframe.size.height = rowHeight + 1;
                    title.text = @"活动描述";
//                    content.text = [_eventInfo valueForKey:@"remark"];
                    break;
                case 3:
                    titleframe.size.height = rowHeight + 1;
                    contentframe.size.height = rowHeight + 1;
                    title.text = @"活动类型";
//                    content.text = [_eventInfo valueForKey:@"remark"];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    [title setFrame:titleframe];
    [content setFrame:contentframe];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            EventEditSubjectViewController* vc = [[EventEditSubjectViewController alloc]init];
            vc.eventInfo = _eventInfo;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    EventEditTimeViewController* vc = [[EventEditTimeViewController alloc]init];
                    vc.eventInfo = _eventInfo;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    EventEditLocationViewController* vc = [[EventEditLocationViewController alloc]init];
                    vc.eventInfo = _eventInfo;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:
                {
                    EventEditRemarkViewController* vc = [[EventEditRemarkViewController alloc]init];
                    vc.eventInfo = _eventInfo;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    EventEditTypeViewController* vc = [[EventEditTypeViewController alloc]init];
                    vc.eventInfo = _eventInfo;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
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
        NSString* bannerPath = [docFolder stringByAppendingPathComponent:@"tmp.jpg"];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:bannerPath])
            [fileManager removeItemAtPath:bannerPath error:nil];
        [[SDImageCache sharedImageCache] removeImageForKey:[_eventInfo valueForKey:@"banner"]];
        
        NSInteger bannercode = _Bannercode;
        //上报封面修改信息
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:_eventId forKey:@"event_id"];
        [dictionary setValue:[NSNumber numberWithInteger:bannercode] forKey:@"code"];
        _Bannercode = -1;
        [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
        NSLog(@"%@",dictionary);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:SET_EVENT_BANNER finshedBlock:^(NSData *rData) {
            if (rData) {
                NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                NSNumber *cmd = [response1 valueForKey:@"cmd"];
                if ([cmd intValue] == NORMAL_REPLY) {
                    [_eventInfo setValue:@(bannercode) forKey:@"code"];
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                    [self refresh];
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

@end
