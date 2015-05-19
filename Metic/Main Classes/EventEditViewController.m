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

#import "EventEditSubjectViewController.h"
#import "EventEditTimeViewController.h"
#import "EventEditLocationViewController.h"
#import "EventEditRemarkViewController.h"

const float rowHeight = 42.0f;
const NSInteger rowCount = 3;

@interface EventEditViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UIImageView* banner;
@property (nonatomic,strong) UITableView* tableView;

@end

@implementation EventEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
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
    [_banner setContentMode:UIViewContentModeScaleAspectFill];
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

- (void)refresh
{
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:_banner authorId:self.eventId];
    NSString* bannerURL = [_eventInfo valueForKey:@"banner"];
    [bannerGetter getBanner:[_eventInfo valueForKey:@"code"] url:bannerURL];
    [_tableView reloadData];
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
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }

}

@end
