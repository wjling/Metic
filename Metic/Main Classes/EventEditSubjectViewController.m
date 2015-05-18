//
//  EventEditSubjectViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditSubjectViewController.h"
#import "CommonUtils.h"
#import "TTTAttributedLabel.h"
#import "SVProgressHUD.h"

@interface EventEditSubjectViewController ()<UITextFieldDelegate>
@property(nonatomic,strong) UITextField* contentField;
@property(nonatomic,strong) TTTAttributedLabel* fontCount;
@property(nonatomic,strong) UILabel* tips;
@end

@implementation EventEditSubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification"  object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动名称";
    
    [self initRightBtn];
    
    _contentField = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame) - 20, 45)];
    _contentField.placeholder = @"请输入活动名称";
    _contentField.font = [UIFont systemFontOfSize:16];
    _contentField.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _contentField.textAlignment = NSTextAlignmentLeft;
    [_contentField setBackgroundColor:[UIColor whiteColor]];
    _contentField.layer.cornerRadius = 6;
    _contentField.layer.masksToBounds = YES;
    _contentField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _contentField.delegate = self;
    
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 45)];
    paddingView.text = @" ";
    paddingView.textColor = [UIColor darkGrayColor];
    paddingView.backgroundColor = [UIColor clearColor];
    _contentField.leftView = paddingView;
    _contentField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_contentField];
    
    _fontCount = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 10 - 50 - 5, CGRectGetMaxY(_contentField.frame) + 5, 50, 20)];
    _fontCount.font = [UIFont systemFontOfSize:13];
    _fontCount.textColor = [UIColor colorWithWhite:0.5 alpha:1.0f];
    _fontCount.textAlignment = NSTextAlignmentRight;
    [_fontCount setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_fontCount];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_contentField.frame) + 25, CGRectGetWidth(_contentField.frame) - 20, 60)];
    
    tips.text = @"取个有趣的活动名称吧! \n修改活动名称后会通知所有活动参与者。";
    tips.numberOfLines = 2;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:13];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.view addSubview:tips];
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

- (void)initData
{
    NSString* content = [_eventInfo valueForKey:@"subject"];
    _contentField.text = content;
    [self setTextCount];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.contentField];
}

- (void)setTextCount
{
    NSInteger textLength = _contentField.text.length;
    if (textLength > 15) {
        textLength = 15;
        _contentField.text = [_contentField.text substringToIndex:15];
    }
    NSString* fontCountText = [NSString stringWithFormat:@"%ld /15",(long)textLength];
    
    [_fontCount setText:fontCountText afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange countRange = NSMakeRange(0, [NSString stringWithFormat:@"%ld",(long)textLength].length);
        UIFont *systemFont = [UIFont systemFontOfSize:13];
        
        if (countRange.location != NSNotFound) {
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:countRange];
            
            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:countRange];
            CFRelease(italicFont);
        }
        return mutableAttributedString;
    }];
}

-(void)confirm
{
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
}

-(void)textFieldEditChanged:(NSNotification*)obj
{
    [self setTextCount];
}

@end
