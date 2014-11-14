//
//  EventDetail2.m
//  WeShare
//
//  Created by ligang6 on 14-11-13.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "EventDetail2.h"
#import "../Source/SDWebImage/UIButton+WebCache.h"

@interface EventDetail2 ()

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIScrollView* SscrollView;
@property (nonatomic,strong) UIScrollView* details;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UIView* indicator;

@end

@implementation EventDetail2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [self.navigationItem setTitle:@"活动详情"];
    
    CGRect frame = self.navigationController.view.window.frame;
    NSLog(@"%f  %f",frame.size.width,frame.size.height);
    frame.size.height -= 64.0f;
    _scrollView = [[UIScrollView alloc]initWithFrame:frame];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    UIButton* banner = [UIButton buttonWithType:UIButtonTypeCustom];
    [banner setFrame:CGRectMake(0, 0, frame.size.width, frame.size.width/2)];
    [banner sd_setImageWithURL:nil forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
    [_scrollView addSubview:banner];
    
    UIView* tabs = [[UIView alloc]initWithFrame:CGRectMake(0, banner.frame.size.height, frame.size.width, 35)];
    [tabs setBackgroundColor:[UIColor colorWithWhite:224.0f/255.0 alpha:1.0f]];
    [_scrollView addSubview:tabs];
    
    UIButton* tab1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [tab1 setTitle:@"活动详情" forState:UIControlStateNormal];
    [tab1.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [tab1 setTitleColor:[UIColor colorWithWhite:68.0f/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [tab1 setFrame:CGRectMake(0, 0, frame.size.width/2-0.5, 30)];
    [tab1 setBackgroundColor:[UIColor whiteColor]];
    [tabs addSubview:tab1];
    
    UIButton* tab2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [tab2 setTitle:@"活动小圈" forState:UIControlStateNormal];
    [tab2.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [tab2 setTitleColor:[UIColor colorWithWhite:68.0f/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [tab2 setFrame:CGRectMake(frame.size.width/2+0.5, 0, frame.size.width/2-0.5, 30)];
    [tab2 setBackgroundColor:[UIColor whiteColor]];
    [tabs addSubview:tab2];
    
    UIView* indicator = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/6, 27, frame.size.width/6, 3)];
    [indicator setBackgroundColor:[UIColor colorWithRed:240.0/255 green:114.0/255 blue:52.0/255 alpha:1.0f]];
    [tabs addSubview:indicator];
    _indicator = indicator;
    
    //活动详情
    UIScrollView* details = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    details.scrollEnabled = NO;
    details.delegate = self;
    details.layer.borderWidth = 2;
    details.layer.borderColor = [UIColor greenColor].CGColor;
    _details = details;
    
    UILabel* label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 80)];
    [label1 setBackgroundColor:[UIColor redColor]];
    [details addSubview:label1];
    
    UILabel* label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 300, 160, 80)];
    [label2 setBackgroundColor:[UIColor greenColor]];
    [details addSubview:label2];
    
    UILabel* label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 600, 160, 80)];
    [label3 setBackgroundColor:[UIColor yellowColor]];
    [details addSubview:label3];
    
    details.contentSize = CGSizeMake(frame.size.width, 1000);
    
    
    
    
    
    //活动小圈
    UITableView* tableView = [[UITableView alloc]initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
    tableView.scrollEnabled = NO;
    tableView.layer.borderWidth = 2;
    tableView.layer.borderColor = [UIColor redColor].CGColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    
    
    float height = details.frame.size.height;
    if (tableView.frame.size.height > height) height = tableView.frame.size.height;
    
    //容器
    CGRect Sframe = frame;
    Sframe.origin.y = CGRectGetMaxY(tabs.frame);
    Sframe.size.height = height;
    NSLog(@"%f",Sframe.origin.y);
    UIScrollView* SscrollView = [[UIScrollView alloc]initWithFrame:Sframe];
    _SscrollView = SscrollView;
    SscrollView.delegate = self;
    SscrollView.layer.borderWidth = 1;
    SscrollView.layer.borderColor = [UIColor yellowColor].CGColor;
    [SscrollView setContentSize:CGSizeMake(Sframe.size.width*2, Sframe.size.height)];
    SscrollView.pagingEnabled = YES;
    
    [SscrollView addSubview:details];
    [SscrollView addSubview:tableView];
    
    [_scrollView addSubview:SscrollView];
    
    [_scrollView setContentSize:CGSizeMake(frame.size.width, CGRectGetMaxY(SscrollView.frame))];
}

#pragma mark 代理方法-UITableView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _SscrollView) {
        CGRect frame = _indicator.frame;
        frame.origin.x = self.navigationController.view.window.frame.size.width/6 + scrollView.contentOffset.x/2;
        _indicator.frame = frame;
    }
    
    if (scrollView == _scrollView) {
        if (_scrollView.contentOffset.y >= CGRectGetMinY(_SscrollView.frame)) {
            if (!_tableView.isScrollEnabled) {
                _tableView.scrollEnabled = YES;
            }
            if (!_details.isScrollEnabled) {
                _details.scrollEnabled = YES;
            }
            
        }else if(_scrollView.contentOffset.y < CGRectGetMinY(_SscrollView.frame)) {
            if (_tableView.isScrollEnabled) {
                _tableView.scrollEnabled = NO;
            }
            if (_details.isScrollEnabled) {
                _details.scrollEnabled = NO;
            }
            
        }
    }
    
    if (scrollView == _tableView){
        if (_tableView.contentOffset.y <= 0 && _tableView.isScrollEnabled) {
            _tableView.scrollEnabled = NO;
        }else if(_tableView.contentOffset.y >= CGRectGetMinY(_SscrollView.frame) && !_tableView.isScrollEnabled){
            _tableView.scrollEnabled = YES;
        }
    }
    
    if (scrollView == _details){
        if (_details.contentOffset.y <= 0 && _details.isScrollEnabled) {
            _details.scrollEnabled = NO;
        }else if(_details.contentOffset.y >= CGRectGetMinY(_SscrollView.frame) && !_details.isScrollEnabled){
            _details.scrollEnabled = YES;
        }
    }
}

#pragma mark 代理方法-UIScrollView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc]init];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 80)];
    [label setBackgroundColor:[UIColor redColor]];
    [cell addSubview:label];
    return cell;
}
@end
