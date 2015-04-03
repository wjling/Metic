//
//  UserInfoViewController.m
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MenuViewController.h"
#import "MobClick.h"
#import "UserQRCodeViewController.h"
#import "UIImageView+LBBlurredImage.h"
#import "BOAlertController.h"
#import "../BannerViewController.h"
#import "KxMenu.h"
#import "UIImage+fixOrien.h"


@interface UserInfoViewController ()
{
    SingleSelectionAlertView* alert;
    NSInteger newGender;
    UIImage* newAvatar;
    UIView* moreFunction_view;
}

@end

@implementation UserInfoViewController
@synthesize banner_UIview;
@synthesize banner_imageView;
@synthesize avatar_imageView;
@synthesize name_label;
@synthesize gender_imageView;
@synthesize email_label;
@synthesize info_tableView;

@synthesize name_vc;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    [CommonUtils addLeftButton:self isFirstPage:!_needPopBack];
    [self initParams];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"UserInfoViewController viewWillAppear");
    UIColor* bgColor = [UIColor colorWithRed:0.82 green:0.85 blue:0.88 alpha:1];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        [self.view setBackgroundColor:bgColor];
    }
    
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"用户主页"];
    [self.view bringSubviewToFront:_shadowView];
    _shadowView.hidden = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"用户主页"];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    NSLog(@"PopToHereAndTurnToNotificationPage  from  UserInfo");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        NSLog(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        NSLog(@"NotHere");
    }
}

-(void)ToNotificationCenter
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
}


- (void)initParams
{
    self.banner_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.banner_UIview.frame.size.width, self.banner_UIview.frame.size.height - 3)];
    self.banner_imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.banner_imageView.clipsToBounds = YES;
    
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:self.avatar_imageView authorId:[MTUser sharedInstance].userid];
    [getter getAvatar];
    self.avatar_imageView.layer.cornerRadius = self.avatar_imageView.frame.size.width/2;
    self.avatar_imageView.layer.masksToBounds = YES;
    self.avatar_imageView.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    self.avatar_imageView.layer.borderWidth = 2;
    
    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAvatar)];
    self.avatar_imageView.userInteractionEnabled = YES;
    [self.avatar_imageView addGestureRecognizer:avatarGesture];
    
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    
    NSNumber* gender = [MTUser sharedInstance].gender;
    NSLog(@"性别gender： %@",gender);
    UIFont* font = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [self.name_label.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, self.name_label.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    self.gender_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.name_label.frame.origin.x + sizeOfName.width + 5, self.name_label.frame.origin.y + 1, 18, 18)];
    if ([gender integerValue] == 0) {
        NSLog(@"性别女");
        self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        NSLog(@"性别男");
        self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    [self.banner_UIview addSubview:self.banner_imageView];
    [self.banner_UIview sendSubviewToBack:self.banner_imageView];
    [self.banner_UIview addSubview:self.gender_imageView];
    self.info_tableView.delegate = self;
    self.info_tableView.dataSource = self;
    self.info_tableView.scrollEnabled = YES;
    
}


-(void)avatarClicked:(id)sender
{
    NSLog(@"avatar clicked");
    BOAlertController *actionSheet = [[BOAlertController alloc] initWithTitle:@"选择图像" message:nil viewController:self];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        NSLog(@"cancel");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
    [actionSheet addButton:cancelItem type:RIButtonItemType_Cancel];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        RIButtonItem *takeItem = [RIButtonItem itemWithLabel:@"拍照" action:^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }];
        [actionSheet addButton:takeItem type:RIButtonItemType_Other];
    }
    
    RIButtonItem *seleteItem = [RIButtonItem itemWithLabel:@"从相册选择" action:^{
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        }else imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    [actionSheet addButton:seleteItem type:RIButtonItemType_Other];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
    [actionSheet showInView:self.view];
}

-(void)QRcodeBtnClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UserQRCodeViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserQRCodeViewController"];
    NSMutableDictionary* userInfo = [CommonUtils packParamsInDictionary:
                                     [MTUser sharedInstance].userid, @"id",
                                     [MTUser sharedInstance].name, @"name",
                                     [MTUser sharedInstance].email, @"email",
                                     nil];
    vc.friendInfo_dic = userInfo;
    [moreFunction_view setHidden:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)rightBarBtnClicked:(id)sender {
    [self showMenu];
}

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = newAvatar;
    UIImage *image = newAvatar;
    newAvatar = nil;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    [controller setKeepingCropAspectRatio:YES];
    [controller setToolbarHidden:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
}

-(void)showAvatar
{
    BannerViewController* bannerView = [[BannerViewController alloc] init];
    bannerView.banner = self.avatar_imageView.image;
    [self presentViewController:bannerView animated:YES completion:^{}];
}

-(void)showMenu
{
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];

    [menuItems addObjectsFromArray:@[
                                     
                                     [KxMenuItem menuItem:@"上传头像"
                                                    image:nil
                                                   target:self
                                                   action:@selector(avatarClicked:)],
                                     
                                     [KxMenuItem menuItem:@"二维码"
                                                    image:nil
                                                   target:self
                                                   action:@selector(QRcodeBtnClicked:)],
                                     ]];
        
        
    [KxMenu setTintColor:[UIColor whiteColor]];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:CGRectMake(self.view.bounds.size.width*0.9, 60, 0, 0)
                 menuItems:menuItems];
}

-(void)refresh
{
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:self.avatar_imageView authorId:[MTUser sharedInstance].userid];
    [getter getAvatarWithCompletion:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.banner_imageView setImageToBlur:self.avatar_imageView.image blurRadius:1.7 brightness: -0.07 completionBlock:nil];
            
//            UIImage* img1 = [image brightness:0.5];
//            UIImage* img2 = [img1 gaussianBlur:5];
//            self.banner_imageView.image = img2;
//            img = [img brightness:0.5];
            
        });
//        UIImage* img = image;
//        img = [img gaussianBlur:5];
//        self.banner_imageView.image = img;
    }];
    
    UIFont* font = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [self.name_label.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, self.name_label.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    NSNumber* gender = [MTUser sharedInstance].gender;
    if (self.gender_imageView) {
        self.gender_imageView.frame = CGRectMake(self.name_label.frame.origin.x + sizeOfName.width + 5, self.name_label.frame.origin.y + 1, 18, 18);
    }
    else
    {
        self.gender_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.name_label.frame.origin.x + sizeOfName.width + 5, self.name_label.frame.origin.y + 1, 18, 18)];
    }
    if ([gender integerValue] == 0) {
        NSLog(@"性别女,gender: %@",gender);
        self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        NSLog(@"性别男,gender: %@",gender);
        self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    [self.info_tableView reloadData];
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [moreFunction_view setHidden:YES];
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
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 75;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
//        return 0;
//    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
//    {
//        return 5;
//    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [moreFunction_view setHidden:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
//                [self performSegueWithIdentifier:@"NameSettingViewController" sender:self];
                
                name_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NameSettingViewController"];
                
                [self.navigationController pushViewController:name_vc animated:YES];
            }
            else if(indexPath.row == 1)
            {
//                NSArray* arr = [[NSArray alloc]initWithObjects:@"女",@"男", nil];
////                SingleSelectionAlertView* alert = [[SingleSelectionAlertView alloc]initWithFrame:CGRectMake(100, 100, 120, 300) withOptionTitles:arr];
//                alert =  [[SingleSelectionAlertView alloc]initWithContentSize:CGSizeMake(300, 400) withTitle:@"修改性别" withOptions:arr];
//                alert.kDelegate = self;
//                alert.tag = 0;
//                [alert show];
                [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"性别无法随意更改" WithDelegate:self WithCancelTitle:@"确定"];
            }
            else if (indexPath.row == 2)
            {
                LocationSettingViewController* location_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LocationSettingViewController"];
                [self.navigationController pushViewController:location_vc animated:YES];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                SignSetttingViewController* sign_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignSetttingViewController"];
                [self.navigationController pushViewController:sign_vc animated:YES];
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"userInfo_securitycenter" sender:self];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  3;
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* borderColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1];
    UIColor* textColor1 = [CommonUtils colorWithValue:0xbfbfbf];
    UIColor* textColor2 = [CommonUtils colorWithValue:0x444444];
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                UserInfoTableViewCell* cell = [self.info_tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
                if (nil == cell) {
                    cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoTableViewCell"];
                }
                cell.title_label.text = @"昵称";
                cell.content_label.text = [MTUser sharedInstance].name;
                cell.title_label.textColor = textColor1;
                cell.content_label.textColor = textColor2;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;

                }
                return cell;
            }
            else if(indexPath.row == 1)
            {
                UserInfoTableViewCell* cell = [self.info_tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
                if (nil == cell) {
                    cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoTableViewCell"];
                }
                cell.title_label.text = @"性别";
                NSNumber* gender = [MTUser sharedInstance].gender;
                if ([gender integerValue] == 0) {
                    cell.content_label.text = @"女";
                }
                else
                {
                    cell.content_label.text = @"男";
                }
                cell.title_label.textColor = textColor1;
                cell.content_label.textColor = textColor2;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;

                }
                return cell;
            }
            else if (indexPath.row == 2)
            {
                UserInfoTableViewCell* cell = [self.info_tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
                if (nil == cell) {
                    cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoTableViewCell"];
                }
                cell.title_label.text = @"所在地";
                NSString* location = [MTUser sharedInstance].location;
                if ( ![location isEqual:[NSNull null]]) {
                    cell.content_label.text = location;
                }
                else
                {
                    cell.content_label.text = @"无";
                }
                cell.title_label.textColor = textColor1;
                cell.content_label.textColor = textColor2;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;

                }
                return cell;
            }
            
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                UserInfoTableViewCell* cell = [self.info_tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
                if (nil == cell) {
                    cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoTableViewCell"];
                }
                cell.title_label.text = @"个人描述";
                cell.content_label.text = @"";
                cell.title_label.textColor = textColor1;
//                cell.content_label.textColor = textColor2;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;
                }
                return cell;
            }
            else if (indexPath.row == 1)
            {
                UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"description"];
                NSString* sign = [MTUser sharedInstance].sign;
                if ( ![sign isEqual:[NSNull null]]) {
                    cell.textLabel.text = sign;
                }
                else
                {
                    cell.textLabel.text = @"无";
                }
                cell.textLabel.textColor = textColor2;
                cell.userInteractionEnabled = NO;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;
                }
                return cell;
            }

        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                UserInfoTableViewCell* cell = [self.info_tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
                if (nil == cell) {
                    cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoTableViewCell"];
                }
                cell.title_label.text = @"安全中心";
                cell.content_label.text = @"";
                cell.title_label.textColor = textColor2;
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
                {
                    cell.layer.borderColor = borderColor.CGColor;
                    cell.layer.borderWidth = 0.3;
                }
                return cell;
            }
        }
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - SingleSelectionAlertViewDelegate
- (void)SingleSelectionAlertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[CustomIOS7AlertView class]]) {
        if (((CustomIOS7AlertView*)alertView).tag == 0) {
            if (buttonIndex == 1) {
                newGender = [alert getSelectedIndex];
                NSDictionary* json = [CommonUtils packParamsInDictionary:
                                      [NSNumber numberWithInteger:newGender],@"gender",
                                      [MTUser sharedInstance].userid,@"id",
                                      nil];
                NSLog(@"gender modify json: %@",json);
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
                NSLog(@"click alert Button");
            }
        }

    }
    else if ([alertView isKindOfClass:[UIButton class]])
    {
        
    }
}


#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//[picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image) image = [UIImage fixOrientation:image];
    newAvatar = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
    PhotoGetter* getter = [[PhotoGetter alloc]initUploadAvatarMethod:croppedImage type:21 viewController:self];
    [getter uploadAvatar];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
}


#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            [MTUser sharedInstance].gender = [NSNumber numberWithInteger:newGender];
            if (newGender == 0) {
                self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
            }
            else
            {
                self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
            }
            NSLog(@"性别修改成功");
        }
            break;
            
        default:
            NSLog(@"性别修改失败");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"由于网络原因性别修改失败" WithDelegate:self WithCancelTitle:@"OK"];
            break;
    }
    [self.info_tableView reloadData];
}


#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return !_needPopBack;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

-(void)sendDistance:(float)distance
{
    [moreFunction_view setHidden:YES];
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
        self.navigationController.navigationBar.alpha = 1 - distance/400.0;
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}




@end
