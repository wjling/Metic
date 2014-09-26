//
//  UserInfoViewController.m
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MobClick.h"


@interface UserInfoViewController ()
{
    SingleSelectionAlertView* alert;
    NSInteger newGender;
    UIImage* newAvatar;
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
    // Do any additional setup after loading the view.
    [CommonUtils addLeftButton:self isFirstPage:!_needPopBack];
    [self initParams];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
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
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"用户主页"];
}

- (void)initParams
{
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:self.avatar_imageView authorId:[MTUser sharedInstance].userid];
    [getter getAvatar];
    self.avatar_imageView.layer.cornerRadius = self.avatar_imageView.frame.size.width/2;
    self.avatar_imageView.layer.masksToBounds = YES;
    self.avatar_imageView.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    self.avatar_imageView.layer.borderWidth = 2;
    
    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClicked:)];
    self.avatar_imageView.userInteractionEnabled = YES;
    [self.avatar_imageView addGestureRecognizer:avatarGesture];
    
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    
    NSNumber* gender = [MTUser sharedInstance].gender;
    UIFont* font = [UIFont systemFontOfSize:15];
    CGSize sizeOfName = [self.name_label.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, self.name_label.frame.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    self.gender_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.name_label.frame.origin.x + sizeOfName.width + 5, self.name_label.frame.origin.y + 1, 18, 18)];
    if (gender == 0) {
        self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    [self.banner_UIview addSubview:self.gender_imageView];
    self.info_tableView.delegate = self;
    self.info_tableView.dataSource = self;
    self.info_tableView.scrollEnabled = YES;
    
}

-(void)avatarClicked:(id)sender
{
    NSLog(@"avatar clicked");
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = newAvatar;
    
    UIImage *image = newAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
}


-(void)refresh
{
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:self.avatar_imageView authorId:[MTUser sharedInstance].userid];
    [getter getAvatar];
    
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
    if (gender == 0) {
        self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    [self.info_tableView reloadData];
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


#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//[picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    newAvatar = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    newAvatar = croppedImage;
    PhotoGetter* getter = [[PhotoGetter alloc]initUploadAvatarMethod:croppedImage type:21 viewController:self];
    [getter uploadAvatar];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
