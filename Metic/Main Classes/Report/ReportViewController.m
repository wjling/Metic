//
//  ReportViewController.m
//  WeShare
//
//  Created by ligang6 on 14-8-24.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ReportViewController.h"
#import "CommonUtils.h"
#import "MobClick.h"


@interface ReportViewController ()

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
    if (_event) {
        NSString*text;
        switch (_type) {
            case 1:
                text = [NSString stringWithFormat:@"举报：%@ 活动\n\n",_event];
                break;
            case 2:
                text = [NSString stringWithFormat:@"举报：%@ 活动图片\n\n",_event];
                break;
            case 3:
                text = [NSString stringWithFormat:@"举报：%@ 活动评论\n\n评论人：%@\n\n评论：%@\n\n",_event,_commentAuthor,_comment];
                break;
            case 4:
                text = [NSString stringWithFormat:@"举报：%@ 活动图片评论\n\n评论人：%@\n\n评论：%@\n\n",_event,_commentAuthor,_comment];
                break;
            default:
                break;
        }
        
        [self.textView setText:text];
    }
}

@end
