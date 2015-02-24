//
//  FillinInfoViewController.m
//  WeShare
//
//  Created by mac on 14-8-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FillinInfoViewController.h"
#import "UIImage+fixOrien.h"

@interface FillinInfoViewController ()
{
    NSMutableArray* heights_arr;
    NSInteger newGender;
    SingleSelectionAlertView* alert;
}

@end

@implementation FillinInfoViewController
@synthesize avatar;
@synthesize info_tableview;
@synthesize email;
@synthesize name;
@synthesize gender;
@synthesize location;
@synthesize sign;

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
    NSLog(@"fillin did load");
    // Do any additional setup after loading the view.
    heights_arr = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 6; i++) {
        if (i == 0) {
            heights_arr[i] = [NSNumber numberWithFloat:60.0];
        }
        else if (i == 5)
        {
            heights_arr[i] = [NSNumber numberWithFloat:90.0];
        }
        else{
            heights_arr[i] = [NSNumber numberWithFloat:40.0];
        }
    }
    
    avatar = [UIImage imageNamed:@"默认用户头像"];
    
    info_tableview.delegate = self;
    info_tableview.dataSource = self;
    
    [CommonUtils addLeftButton:self isFirstPage:NO];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    NSLog(@"fillin will apear");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"fillin did appear, email: %@",email);
    self.navigationController.navigationItem.leftBarButtonItem = nil;
    [self.info_tableview reloadData];
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

- (IBAction)okBtnClicked:(id)sender {
    
    if (![MTUser sharedInstance].name || [[MTUser sharedInstance].name isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"请填写您的昵称" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    [self performSegueWithIdentifier:@"fillinInfo_home" sender:sender];
//    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIColor* borderColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1];
    UIColor* textColor1 = [CommonUtils colorWithValue:0xbfbfbf];
    UIColor* textColor2 = [CommonUtils colorWithValue:0x444444];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell* cell;
    
    if (section == 0) {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"avatar"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"avatar"];
            }
            UIImageView* imageview = (UIImageView*)[cell viewWithTag:01];
            if (!imageview) {
                imageview = [[UIImageView alloc]initWithFrame:CGRectMake(230, 5, 50, 50)];
                imageview.tag = 01;
                [cell addSubview:imageview];
            }
            imageview.image = avatar;
            
            cell.textLabel.text = @"头像";
            cell.textLabel.textColor = textColor1;
            
        }
    }
    else if (section == 1)
    {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"name"];
            }
            cell.textLabel.text = @"昵称";
            cell.textLabel.textColor = textColor1;
            
            UILabel *label = (UILabel*)[cell.contentView viewWithTag:10];
            if (!label) {
                label = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 220, 30)];
                label.tag = 10;
                label.textAlignment = NSTextAlignmentRight;
                [label setBackgroundColor:[UIColor clearColor]];
                label.textColor = textColor2;
                [cell.contentView addSubview:label];
            }
//            NSLog(@"昵称: %@",[MTUser sharedInstance].name);
            if ([MTUser sharedInstance].name) {
                label.text = [MTUser sharedInstance].name;
            }
            else
            {
                label.text = @"";
            }
        }
        else if (row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"gender"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gender"];
            }
            cell.textLabel.text = @"性别";
            cell.textLabel.textColor = textColor1;
            
            UILabel *label = (UILabel*)[cell.contentView viewWithTag:11];
            if (!label) {
                label = [[UILabel alloc]initWithFrame:CGRectMake(230, 5, 50, 30)];
                label.tag = 11;
                label.textAlignment = NSTextAlignmentRight;
                [label setBackgroundColor:[UIColor clearColor]];
                label.textColor = textColor2;
                [cell.contentView addSubview:label];
            }
            NSLog(@"性别：%@",gender);
            if ([MTUser sharedInstance].gender) {
                gender = [MTUser sharedInstance].gender;
            }
            if ([gender integerValue] == 1) {
                label.text = @"男";
            }
            else
            {
                label.text = @"女";
            }
        }
        else if (row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"location"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"location"];
            }
            cell.textLabel.text = @"所在地";
            cell.textLabel.textColor = textColor1;
            
            UILabel* label = (UILabel*)[cell.contentView viewWithTag:12];
            if (!label) {
                label = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 220, 30)];
                label.tag = 12;
                label.textAlignment = NSTextAlignmentRight;
                [label setBackgroundColor:[UIColor clearColor]];
                label.textColor = textColor2;
                [cell.contentView addSubview:label];
            }
            
            if ([MTUser sharedInstance].location) {
                label.text = [MTUser sharedInstance].location;
//                NSLog(@"所在地1:%@",[MTUser sharedInstance].location);
            }
            else
            {
//                NSLog(@"所在地2:%@",[MTUser sharedInstance].location);
                label.text = @"暂无地址";
            }
        }
    }
    else if (section == 2)
    {
        if (row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sign"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sign"];
            }
            cell.textLabel.text = @"个人描述";
            cell.textLabel.textColor = textColor1;
        }
        else if (row == 1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"signcontent"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"signcontent"];
            }
            
            UILabel* label = (UILabel*)[cell.contentView viewWithTag:21];
            if (!label) {
                label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 260, 90)];
                label.tag = 21;
//                label.textAlignment = NSTextAlignmentRight;
                [label setBackgroundColor:[UIColor clearColor]];
                label.textColor = textColor2;
                [cell.contentView addSubview:label];
            }
//            NSLog(@"个人描述:%@",[MTUser sharedInstance].sign);
            if ([MTUser sharedInstance].sign) {
                label.text = [MTUser sharedInstance].sign;
            }
            else
            {
                label.text = @"无";
            }
            cell.userInteractionEnabled = NO;

        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        return [heights_arr[row] floatValue];
    }
    else if (section == 1)
    {
        return [heights_arr[row + 1] floatValue];
    }
    else if (section == 2)
    {
        return [heights_arr[row + 4] floatValue];
    }
    else
    {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    
    if (section == 0) {
        if (row == 0) {
            [self changeAvatar];
        }
    }
    else if (section == 1)
    {
        if (row == 0) {
            NameSettingViewController* name_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NameSettingViewController"];
            [self.navigationController pushViewController:name_vc animated:YES];
        }
        else if (row == 1)
        {
            NSArray* arr = [[NSArray alloc]initWithObjects:@"女",@"男", nil];
            alert =  [[SingleSelectionAlertView alloc]initWithContentSize:CGSizeMake(300, 400) withTitle:@"修改性别" withOptions:arr];
            alert.kDelegate = self;
            alert.tag = 0;
            [alert show];
        }
        else if (row == 2)
        {
            LocationSettingViewController* location_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LocationSettingViewController"];
            [self.navigationController pushViewController:location_vc animated:YES];
        }
    }
    else if (section == 2)
    {
        if (row == 0) {
            SignSetttingViewController* sign_vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SignSetttingViewController"];
            [self.navigationController pushViewController:sign_vc animated:YES];
        }
    }
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
            NSLog(@"性别修改成功");
        }
            break;
            
        default:
            NSLog(@"性别修改失败");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"由于网络原因性别修改失败" WithDelegate:self WithCancelTitle:@"OK"];
            break;
    }
    [self.info_tableview reloadData];
}




//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝UPLOAD AVATAR＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
-(void)changeAvatar
{
    NSLog(@"change avatar");
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
    controller.image = avatar;
    
    UIImage *image = avatar;
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
    if (image) image = [UIImage fixOrientation:image];
    avatar = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    avatar = croppedImage;
    PhotoGetter* getter = [[PhotoGetter alloc]initUploadAvatarMethod:croppedImage type:22 viewController:self];
    [getter uploadAvatar];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}




@end
