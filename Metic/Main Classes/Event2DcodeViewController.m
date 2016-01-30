//
//  Event2DcodeViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "Event2DcodeViewController.h"
#import "UMSocial.h"
#import "PhotoGetter.h"
#import "MobClick.h"
#import "QRCodeGenerator.h"
#import "SocialSnsApi.h"

@interface Event2DcodeViewController ()
@property(nonatomic,strong) UIImage* event2Dcode;
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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self fillingInfo];
    [self getQRcode];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"活动二维码"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动二维码"];
    
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


-(void)fillingInfo
{
    _activity.text = [_eventInfo valueForKey:@"subject"];
    _launcher.text = [NSString stringWithFormat:@"发起人：%@",[_eventInfo valueForKey:@"launcher"]];
    NSNumber* launcherId = [_eventInfo valueForKey:@"launcher_id"];
    float colorValue = 232.0/255;
    [[_TwodCode superview].layer setBorderColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0].CGColor];
    [[_TwodCode superview].layer setBorderWidth:1];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:_avatar authorId:launcherId];
    [getter getAvatar];
    
    
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
    _TwodCode.image = [QRCodeGenerator qrImageForString:QRCODE_STRING imageSize:1000];
//    _TwodCode.image = [QREncoder encode:QRCODE_STRING];
    [_TwodCode layer].magnificationFilter = kCAFilterNearest;
    _event2Dcode = [CommonUtils convertViewToImage:_mainView];
}
- (IBAction)shareQRcode:(id)sender {
    if (_event2Dcode) {

        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
        [UMSocialData defaultData].extConfig.sinaData.urlResource = nil;

        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline]];
        NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
        if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
            [shareToSns addObject:UMShareToSms];
        }
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:@""
                                         shareImage:_event2Dcode
                                    shareToSnsNames:shareToSns
                                           delegate:self];
    }
}

- (IBAction)saveQRcode:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum(_event2Dcode,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    if (error){
        // Do anything needed to handle the error or display it to the user
    }else{
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"保存成功" WithDelegate:self WithCancelTitle:@"确定"];
    }
}

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        MTLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"成功分享" WithDelegate:self WithCancelTitle:@"确定"];
    }
}
@end


