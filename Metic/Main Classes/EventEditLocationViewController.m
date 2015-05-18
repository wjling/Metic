//
//  EventEditLocationViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditLocationViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"

@interface EventEditLocationViewController ()
@property(nonatomic,strong) UITextField* contentField;
@property(nonatomic,strong) UIView* clearLocView;
@property(nonatomic,strong) UIButton* clearLocBtn;
@property(nonatomic,strong) UIView* getLocView;
@property(nonatomic,strong) UIButton* getLocBtn;
@end

@implementation EventEditLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动地点";
    
    [self initRightBtn];
    
    _contentField = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame) - 20, 45)];
    _contentField.font = [UIFont systemFontOfSize:16];
    _contentField.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _contentField.textAlignment = NSTextAlignmentLeft;
    [_contentField setBackgroundColor:[UIColor whiteColor]];
    _contentField.layer.cornerRadius = 6;
    _contentField.layer.masksToBounds = YES;
    _contentField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _contentField.placeholder = @"请输入活动地点";
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 45)];
    paddingView.text = @" ";
    paddingView.textColor = [UIColor darkGrayColor];
    paddingView.backgroundColor = [UIColor clearColor];
    _contentField.leftView = paddingView;
    _contentField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_contentField];
    
    _clearLocView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_contentField.frame)+10, CGRectGetWidth(_contentField.frame), 45)];
    _clearLocView.backgroundColor = [UIColor clearColor];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 25)];
    lab.text = @"已定位，你可以";
    lab.numberOfLines = 1;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
    [_clearLocView addSubview:lab];
    
    _clearLocBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_clearLocBtn setTitle:@"清除当前定位信息" forState:UIControlStateNormal];
    _clearLocBtn.frame = CGRectMake(CGRectGetMaxX(lab.frame), 5, 120, 35);
    [_clearLocBtn setTitleColor:[UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    _clearLocBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_clearLocBtn addTarget:self action:@selector(clearLoc) forControlEvents:UIControlEventTouchUpInside];
    [_clearLocView addSubview:_clearLocBtn];
    
    _getLocView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_contentField.frame)+10, CGRectGetWidth(self.view.frame), 200)];
    [_getLocView setBackgroundColor:[UIColor clearColor]];
    
    _getLocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _getLocBtn.frame = CGRectMake(10, 0, CGRectGetWidth(self.view.frame) - 20, 45);
    _getLocBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_getLocBtn setTitle:@"我要定位" forState:UIControlStateNormal];
    [_getLocBtn setTitleColor:[UIColor colorWithWhite:0.97f alpha:1.0f]  forState:UIControlStateNormal];
    [_getLocBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85.0/255.0 green:203.0/255.0 blue:171.0/255.0 alpha:1.0f]] forState:UIControlStateNormal];
    [_getLocBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:68.0/255.0 green:162.4/255.0 blue:136.8/255.0 alpha:1.0f]] forState:UIControlStateHighlighted];
    _getLocBtn.layer.cornerRadius = 6;
    _getLocBtn.layer.masksToBounds = YES;
    [_getLocBtn addTarget:self action:@selector(getLoc) forControlEvents:UIControlEventTouchUpInside];
    [_getLocView addSubview:_getLocBtn];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_getLocBtn.frame)+10, CGRectGetWidth(_getLocView.frame) - 30, 80)];
    
    tips.text = @"定位后会把活动定位在你设定的位置上，人们可以通过附近的活动找到你的活动。\n\n修改活动地点后会通知所有活动参与者";
    tips.numberOfLines = 0;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:14];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [_getLocView addSubview:tips];
    
    
}

- (void)initData
{
    NSString* loc = [_eventInfo valueForKey:@"location"];
    if (loc) {
        _contentField.text = loc;
    }
    
    double latitude = [[_eventInfo valueForKey:@"latitude"] doubleValue];
    double longitude = [[_eventInfo valueForKey:@"longitude"] doubleValue];
    CGRect frame = _contentField.frame;
    if ((latitude == 999.999999 && longitude == 999.999999)) {
        CGRect clearlocFrame = _clearLocView.frame;
        clearlocFrame.origin.y = CGRectGetMaxY(frame);
        [_clearLocView setFrame:clearlocFrame];
        [self.view addSubview:_clearLocView];
        frame = clearlocFrame;
    }else{
        [_clearLocView removeFromSuperview];
        frame.size.height += 20;
    }
    
    CGRect getlocFrame = _getLocView.frame;
    getlocFrame.origin.y = CGRectGetMaxY(frame);
    [_getLocView setFrame:getlocFrame];
    [self.view addSubview:_getLocView];
    
}

- (void)initRightBtn
{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(10, 2.5f, 51, 28)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"小按钮绿色"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [rightButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [rightButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void)clearLoc
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
}

-(void)getLoc
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
}

-(void)confirm
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
}

@end
