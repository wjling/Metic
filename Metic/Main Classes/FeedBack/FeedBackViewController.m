//
//  FeedBackViewController.m
//  Metic
//
//  Created by mac on 14-7-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FeedBackViewController.h"
#import "MobClick.h"

@interface FeedBackViewController ()
{
    CGRect mFrame;
}

@end

@implementation FeedBackViewController
@synthesize rootView;

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
    [CommonUtils addLeftButton:self isFirstPage:YES];
    // Do any additional setup after loading the view.
    self.content_textView.font = [UIFont systemFontOfSize:13];
    self.content_textView.delegate = self.rootView;
    UIColor *color = [CommonUtils colorWithValue:0xcfcfcf];
    self.content_textView.layer.borderColor = color.CGColor;
    self.content_textView.layer.borderWidth = 1;
    self.content_textView.layer.cornerRadius = 3.5;
    self.content_textView.layer.masksToBounds = YES;
//    self.content_textView.text = @"意见反馈";
//    [self.content_textView selectAll:self];
    
    self.contact1_textField.delegate = rootView;
    self.contact1_textField.font = [UIFont systemFontOfSize:13];
    self.contact1_textField.layer.borderColor = color.CGColor;
    self.contact1_textField.layer.borderWidth = 1;
    self.contact1_textField.placeholder = @"联系方式、手机或邮箱（选填）";
    self.contact1_textField.layer.cornerRadius = 3.5;
    self.contact1_textField.layer.masksToBounds = YES;
    self.contact1_textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.contact1_textField.leftViewMode = UITextFieldViewModeAlways;
    rootView.myDelegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"反馈"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"反馈"];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)backgroundBtn:(id)sender
{
    //    [sender resignFirstResponder];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


- (IBAction)confrim_button:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    NSString* content = self.content_textView.text;
    if ([content isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请输入你的宝贵意见" WithDelegate:self WithCancelTitle:@"OK"];
        return;
    }
    NSString* contact = self.contact1_textField.text;
    
    NSString* message = [NSString stringWithFormat:@"%@\n\nContact: %@\nUID: %@\nUser Name: %@\n(FROM IOS CLIENT)",
                         content,contact,[MTUser sharedInstance].userid,[MTUser sharedInstance].name];
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          message,@"content",
                          nil];
    MTLOG(@"feed back json : %@",json);

    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendFeedBackMessage:json];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    mFrame = textView.frame;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:13.0];
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(mFrame.size.width-16, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    [textView setFrame:CGRectMake(mFrame.origin.x, mFrame.origin.y, mFrame.size.width, size.height+font.capHeight+16)];
    return YES;
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp1 = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSString* temp2 = [temp1 stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    rData = [temp2 dataUsingEncoding:NSUTF8StringEncoding];
    
    MTLOG(@"Received string1: %@",temp1);
    MTLOG(@"Received string2: %@",temp2);
    
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"response dic: %@",response1);
    MTLOG(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            MTLOG(@"意见反馈发送成功");
            self.content_textView.text = @"";
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"意见反馈发送成功，非常感谢您的支持" WithDelegate:self WithCancelTitle:@"OK"];
        }
            break;
        default:
            MTLOG(@"意见反馈发送失败");
            break;
    }
    
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        self.shadowView.hidden = NO;
        
        [self.view bringSubviewToFront:self.shadowView];
        
        [self.shadowView setAlpha:distance/(kMainScreenWidth * 1.2f)];
        
        self.navigationController.navigationBar.alpha = 1 - distance/(kMainScreenWidth * 1.2f);
        
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}


@end
