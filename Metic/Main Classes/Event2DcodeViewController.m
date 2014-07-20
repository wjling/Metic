//
//  Event2DcodeViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "Event2DcodeViewController.h"
#import "../Utils/PhotoGetter.h"

@interface Event2DcodeViewController ()

@end

@implementation Event2DcodeViewController

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
    [self fillingInfo];
    [self getQRcode];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillingInfo
{
    _activity.text = [_eventInfo valueForKey:@"subject"];
    _launcher.text = [NSString stringWithFormat:@"发起人：%@",[_eventInfo valueForKey:@"launcher"]];
    NSNumber* launcherId = [_eventInfo valueForKey:@"launcher_id"];
    float colorValue = 232.0/255;
    [[_TwodCode superview].layer setBorderColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0].CGColor];
    [[_TwodCode superview].layer setBorderWidth:1];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:_avatar authorId:launcherId];
    [getter getPhoto];
    
    
}


-(void)getQRcode
{
    NSString* url = @"http://www.whatsact.com";
    NSString* type = @"/event/";
    NSString* text= [NSString stringWithFormat:@"edcba%@",_eventId];
    text = [CommonUtils base64StringFromText:text];
    NSString* ID_STRING = [CommonUtils stringByReversed:[text substringToIndex:text.length-3]];
    ID_STRING = [ID_STRING stringByAppendingString:[text substringWithRange:NSMakeRange(text.length-3, 3)]];
    NSString* QRCODE_STRING = [NSString stringWithFormat:@"%@%@%@",url,type,ID_STRING];
    NSLog(QRCODE_STRING,nil);
    //_TwodCode.image = [QREncoder encode:QRCODE_STRING];
}
- (IBAction)shareQRcode:(id)sender {
}

- (IBAction)saveQRcode:(id)sender {
}
@end


