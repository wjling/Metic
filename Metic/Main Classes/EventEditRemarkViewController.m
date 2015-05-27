//
//  EventEditRemarkViewController.m
//  WeShare
//
//  Created by 俊健 on 15/5/11.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventEditRemarkViewController.h"
#import "CommonUtils.h"
#import "SVProgressHUD.h"
#import "MTUser.h"
#import "MTDatabaseAffairs.h"

const float textViewHeight = 120;
const float keyboardHeight = 310;
const float keyboardleft = 0;

@interface EventEditRemarkViewController ()<UITextViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView* scrollView;
@property(nonatomic,strong) UITextView* textView;
@property(nonatomic,strong) UILabel* tips;
@property(nonatomic,strong) UIButton* confirmBtn;
@end

@implementation EventEditRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    [_textView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.title = @"修改活动描述";
    
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    _scrollView.scrollEnabled = YES;
    _scrollView.delegate = self;
    [self initRightBtn];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame) - 20, textViewHeight)];
     [_textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    _textView.textAlignment = NSTextAlignmentLeft;
    [_textView setBackgroundColor:[UIColor whiteColor]];
    _textView.layer.cornerRadius = 7;
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderWidth = 2;
    _textView.layer.borderColor = [UIColor colorWithWhite:0.94f alpha:1.0f].CGColor;
    _textView.delegate = self;
    [self.scrollView addSubview:_textView];
    
    UILabel* tips = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_textView.frame) + 10, CGRectGetWidth(_textView.frame) - 20, 30)];
    _tips = tips;
    tips.text = @"修改活动描述后会通知所有活动参与者。";
    tips.numberOfLines = 2;
    tips.textAlignment = NSTextAlignmentLeft;
    tips.font = [UIFont systemFontOfSize:13];
    tips.textColor = [UIColor colorWithWhite:0.6f alpha:1.0f];
    [self.scrollView addSubview:tips];
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(tips.frame) + 20);
    _scrollView.contentSize = size;
}

-(void)initData
{
    NSString* content = [_eventInfo valueForKey:@"remark"];
    _textView.text = content;
}

- (void)initRightBtn
{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn = rightButton;
    [rightButton setFrame:CGRectMake(10, 2.5f, 51, 28)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"小按钮绿色"] forState:UIControlStateNormal];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [rightButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [rightButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void)confirm
{
    [_textView resignFirstResponder];
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
    
    NSString* content = [NSString stringWithString: _textView.text];
    if (!content || [content isEqualToString:[_eventInfo valueForKey:@"remark"]]) {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD dismissWithSuccess:@"修改成功"];
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[_eventInfo valueForKey:@"event_id"] forKey:@"event_id"];
    [dictionary setValue:content forKey:@"remark"];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:CHANGE_EVENT_INFO finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    [SVProgressHUD dismissWithSuccess:@"修改成功"];
                    [_eventInfo setValue:content forKey:@"remark"];
                    [[MTDatabaseAffairs sharedInstance]saveEventToDB:_eventInfo];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                case EVENT_NOT_EXIST:
                {
                    [SVProgressHUD dismissWithError:@"活动不存在"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                case REQUEST_DATA_ERROR:
                {
                    [SVProgressHUD dismissWithError:@"没有修改权限"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                default:
                {
                    [SVProgressHUD dismissWithError:@"服务器异常"];
                }
            }
        }else{
            [SVProgressHUD dismissWithError:@"网络异常"];
        }
    }];
    
}

-(void)adjustTextView
{
    if (_scrollView.contentSize.height <= CGRectGetHeight(_scrollView.frame)) {
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
    CGSize size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tips.frame) + 20);
    _scrollView.contentSize = size;
}

#pragma mark - UIScrollView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        [_textView resignFirstResponder];
    }
}
#pragma mark - TextView delegate
-(void)textViewDidChange:(UITextView *)textView
{

}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self adjustTextView];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self observeValueForKeyPath:@"contentSize" ofObject:_textView change:nil context:nil];
    return YES;
}
-(void)textViewDidChangeSelection:(UITextView *)textView
{
    [self observeValueForKeyPath:@"contentSize" ofObject:_textView change:nil context:nil];
    NSLog(@"sdfadf");
}

- (void)observeValueForKeyPath:(NSString *)keyPath

                      ofObject:(id)object

                        change:(NSDictionary *)change

                       context:(void *)context

{
    
    // 监听textview 的contensize是否改变
    
    if ([keyPath isEqualToString:@"contentSize"])
        
    {
        
        UITextView *view = object;
        
        // 获取textView最新的contentSize的高度
        
        CGFloat contentHeight = view.contentSize.height;
        
        CGSize scrollViewContentSize = _scrollView.contentSize;
        
        if (contentHeight > textViewHeight) {     // 346 是textview的默认高度
            
            CGRect frame = view.frame;
            
            frame.size.height = contentHeight;   // 50 是底部间距
            
            view.frame = frame;
            
            [_tips setFrame:CGRectMake(20, CGRectGetMaxY(_textView.frame) + 10, CGRectGetWidth(_textView.frame) - 20, 30)];
            
            scrollViewContentSize.height = CGRectGetMaxY(_tips.frame) + 20 + keyboardHeight;
            
        }else {
            
            scrollViewContentSize.height = CGRectGetMaxY(_tips.frame) + 20 + keyboardHeight;
            
        }
        
        _scrollView.contentSize = scrollViewContentSize;
        
        // 获取光标的位置区域
        
        CGRect cursorPosition = [view caretRectForPosition:view.selectedTextRange.start];
        
        // 光标相对顶层视图（scrollView）frame的坐标高度
        
        CGFloat height = cursorPosition.origin.y + view.frame.origin.y - _scrollView.contentOffset.y;
        
        //
        
        CGFloat currentPoint = cursorPosition.origin.y;
        
        // 可见scrollView区域， 由于键盘有中英输入法，所以会导致可见区域的变化
        
        CGFloat cursorValueMax = [UIScreen mainScreen].bounds.size.height - 64 - keyboardHeight;
        
        if (height > cursorValueMax - keyboardleft) {   // 当光标在可见区域底部50pix内，即距离键盘50pix内
            
            [_scrollView setContentOffset:CGPointMake(0, currentPoint + view.frame.origin.y - cursorValueMax + keyboardleft) animated:NO];
            
        } else if (height < 20) {                     // 当光标在可见区域顶部20pix内，即距离顶部20pix内 
            
            [_scrollView scrollRectToVisible:CGRectMake(0, cursorPosition.origin.y - 20, 320, 60) animated:NO];
            
        }
        
    }
    
}
@end
