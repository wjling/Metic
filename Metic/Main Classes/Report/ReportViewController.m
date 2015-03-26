//
//  ReportViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ReportViewController.h"
#import "../../Utils/HttpSender.h"
#import "CommonUtils.h"
#import "MobClick.h"
#import "MTUser.h"


@interface ReportViewController ()
@property (nonatomic,strong) UIView* waitingView;
@end

@implementation ReportViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self initFormat];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"举报"];
    [self.titleTextField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"举报"];
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

-(void)initFormat
{
    if (_event || _userId) {
        NSString*text;
        switch (_type) {
            case 0:
                text = [NSString stringWithFormat:@"举报用户：%@ \n\n",_userName];
                break;
            case 1:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动\n\n",_event];
                break;
            case 2:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动评论\n\n评论人：%@\n\n评论：%@\n\n",_event,_commentAuthor,_comment];
                break;
            case 3:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动图片\n\n",_event];
                break;
            case 4:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动图片评论\n\n评论人：%@\n\n评论：%@\n\n",_event,_commentAuthor,_comment];
                break;
            case 5:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动视频\n\n",_event];
                break;
            case 6:
                text = [NSString stringWithFormat:@"举报：⎡%@⎦ 活动视频评论\n\n评论人：%@\n\n评论：%@\n\n",_event,_commentAuthor,_comment];
                break;
            default:
                break;
        }
        
        [self.textView setText:text];
    }
}

- (IBAction)confirm:(id)sender {
    [self.confirm_Button setEnabled:NO];
    [self.textView resignFirstResponder];
    [self.titleTextField resignFirstResponder];
    [self showWaitingView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self) {
            [self removeWaitingView];
            [self.confirm_Button setEnabled:YES];
        }
    });
    
    
    NSNumber* object_id;
    switch (_type) {
        case 0:
            object_id = _userId;
            break;
        case 1:
            object_id = _eventId;
            break;
        case 2:
            object_id = _commentId;
            break;
        case 3:
            object_id = _photoId;
            break;
        case 4:
            object_id = _pcommentId;
            break;
        case 5:
            object_id = _videoId;
            break;
        case 6:
            object_id = _vcommentId;
            break;
            
        default:
            object_id = [NSNumber numberWithInteger:-1];
            break;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:_type] forKey:@"type"];
    [dictionary setValue:object_id forKey:@"object_id"];
    [dictionary setValue:_textView.text forKey:@"content"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:COMPLAIN finshedBlock:^(NSData *rData) {
        if (rData) {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"感谢投诉" WithMessage:@"谢谢你！活动宝坚决反对色情、暴力、欺诈等不良信息，我们会认真处理你的投诉。" WithDelegate:self WithCancelTitle:@"确定"];
                    [alert setTag:101];
                }
                    break;
                default:{
                    UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:self WithCancelTitle:@"确定"];
                    [alert setTag:102];
                }
                    break;
            }
        }else{
            UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"网络异常，请重试。" WithDelegate:self WithCancelTitle:@"确定"];
            [alert setTag:102];
        }
        
    }];
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
        [_waitingView addSubview:indicator];
        [self.view addSubview:_waitingView];
        [indicator startAnimating];
    }
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [_waitingView removeFromSuperview];
        _waitingView = nil;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            switch ([alertView tag]) {
                case 101:
                    [self removeWaitingView];
                    [self.confirm_Button setEnabled:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                case 102:{
                    [self removeWaitingView];
                    [self.confirm_Button setEnabled:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}
@end
