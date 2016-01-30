//
//  UserQRCodeViewController.m
//  WeShare
//
//  Created by mac on 14-9-1.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserQRCodeViewController.h"
#import "QRCodeGenerator.h"
#import "SocialSnsApi.h"

@interface UserQRCodeViewController ()
{
    UIImage* friendQRcode;
}

@end

@implementation UserQRCodeViewController
@synthesize mainView;
@synthesize avatar;
@synthesize fname_label;
@synthesize femail_label;
@synthesize QRcode_imageview;
@synthesize fid;
@synthesize friendInfo_dic;


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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self fillingInfo];
    [self getQRcode];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"好友二维码"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"好友二维码"];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)fillingInfo
{
    fname_label.text = [friendInfo_dic valueForKey:@"name"];
    femail_label.text = [friendInfo_dic valueForKey:@"email"];
    fid = [friendInfo_dic valueForKey:@"id"];
    float colorValue = 232.0/255;
    [[QRcode_imageview superview].layer setBorderColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0].CGColor];
    [[QRcode_imageview superview].layer setBorderWidth:1];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:fid];
    [getter getAvatar];
    
    
}

-(void)getQRcode
{
    NSString* url = @"http://www.whatsact.com";
    NSString* type = @"/user/";
    NSString* text= [NSString stringWithFormat:@"abcde%@",fid];
    text = [CommonUtils base64StringFromText:text];
    NSString* ID_STRING = [CommonUtils stringByReversed:[text substringToIndex:text.length-3]];
    ID_STRING = [ID_STRING stringByAppendingString:[text substringWithRange:NSMakeRange(text.length-3, 3)]];
    NSString* QRCODE_STRING = [NSString stringWithFormat:@"%@%@%@",url,type,ID_STRING];
    QRcode_imageview.image = [QRCodeGenerator qrImageForString:QRCODE_STRING imageSize:1000];
//    QRcode_imageview.image = [QREncoder encode:QRCODE_STRING];
    [QRcode_imageview layer].magnificationFilter = kCAFilterNearest;
    friendQRcode = [CommonUtils convertViewToImage:mainView];
}


- (IBAction)shareQRcode:(id)sender {
    if (friendQRcode) {

        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
        [UMSocialData defaultData].extConfig.qqData.title = @"【活动宝用户推荐】";
        [UMSocialData defaultData].extConfig.sinaData.urlResource = nil;
        [UMSocialData defaultData].extConfig.smsData.urlResource = nil;

        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];
        NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
        if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
            [shareToSns addObject:UMShareToSms];
        }
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"53bb542e56240ba6e80a4bfb"
                                          shareText:@" "
                                         shareImage:friendQRcode
                                    shareToSnsNames:shareToSns
                                           delegate:self];
    }
}

- (IBAction)saveQRcode:(id)sender {
    UIImageWriteToSavedPhotosAlbum(friendQRcode,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
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
