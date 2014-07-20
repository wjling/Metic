//
//  FeedBackViewController.m
//  Metic
//
//  Created by mac on 14-7-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FeedBackViewController.h"

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
    // Do any additional setup after loading the view.
    self.content_textView.font = [UIFont systemFontOfSize:14];
    self.content_textView.delegate = self.rootView;
    UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    self.content_textView.layer.borderColor = color.CGColor;
    self.content_textView.layer.borderWidth = 2;
    self.contact2_textField.text = [MTUser sharedInstance].email;
    
    self.contact1_textField.delegate = rootView;
    self.contact2_textField.delegate = rootView;
    rootView.myDelegate = self;
    
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
    
    NSString* content = self.content_textView.text;
    if ([content isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请输入你的宝贵意见" WithDelegate:self WithCancelTitle:@"OK"];
        return;
    }
    NSString* contact_qq = self.contact1_textField.text;
    NSString* contact_mail = self.contact2_textField.text;
    
    NSString* message = [NSString stringWithFormat:@"%@\nQQ:%@\nE-mail:%@",content,contact_qq,contact_mail];
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          message,@"content",
                          nil];
    NSLog(@"feed back json : %@",json);

    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendFeedBackMessage:json];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    mFrame = textView.frame;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize size = [textView.text sizeWithFont:font constrainedToSize:CGSizeMake(mFrame.size.width-16, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    [textView setFrame:CGRectMake(mFrame.origin.x, mFrame.origin.y, mFrame.size.width, size.height+font.capHeight+16)];
//    NSLog(@"char height : %f",size.height);
//    NSLog(@"textview height: %f",textView.frame.size.height);
    return YES;
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp1 = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSString* temp2 = [temp1 stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    rData = [temp2 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Received string1: %@",temp1);
    NSLog(@"Received string2: %@",temp2);
    
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"response dic: %@",response1);
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            NSLog(@"意见反馈发送成功");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"意见反馈发送成功，非常感谢您的支持" WithDelegate:self WithCancelTitle:@"OK"];
        }
            break;
        default:
            NSLog(@"意见反馈发送失败");
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
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}


@end
