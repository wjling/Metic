//
//  UserInfoViewController.m
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserInfoViewController.h"


@interface UserInfoViewController ()
{
    SingleSelectionAlertView* alert;
    NSInteger newGender;
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
    [self initParams];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"UserInfoViewController viewWillAppear");
    [self refresh];
}

- (void)initParams
{
    PhotoGetter* getter = [[PhotoGetter alloc]initWithData:self.avatar_imageView authorId:[MTUser sharedInstance].userid];
    [getter getPhoto];
    self.avatar_imageView.layer.cornerRadius = self.avatar_imageView.frame.size.width/2;
    self.avatar_imageView.layer.masksToBounds = YES;
    self.avatar_imageView.layer.borderColor = ([UIColor lightGrayColor].CGColor);
    self.avatar_imageView.layer.borderWidth = 2;
    
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    
    NSNumber* gender = [MTUser sharedInstance].gender;
    if (gender == 0) {
        self.gender_imageView.image = [UIImage imageNamed:@"女icon"];
    }
    else
    {
        self.gender_imageView.image = [UIImage imageNamed:@"男icon"];
    }
    
    self.info_tableView.delegate = self;
    self.info_tableView.dataSource = self;
    self.info_tableView.scrollEnabled = YES;
    
}

-(void)refresh
{
    self.name_label.text = [MTUser sharedInstance].name;
    self.email_label.text = [MTUser sharedInstance].email;
    
    NSNumber* gender = [MTUser sharedInstance].gender;
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
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                NSArray* arr = [[NSArray alloc]initWithObjects:@"女",@"男", nil];
//                SingleSelectionAlertView* alert = [[SingleSelectionAlertView alloc]initWithFrame:CGRectMake(100, 100, 120, 300) withOptionTitles:arr];
                alert =  [[SingleSelectionAlertView alloc]initWithContentSize:CGSizeMake(300, 400) withTitle:@"修改性别" withOptions:arr];
                alert.kDelegate = self;
                alert.tag = 0;
                [alert show];
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
                
                cell.userInteractionEnabled = NO;
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
    [self.info_tableView reloadData];
}


#pragma mark - SlideNavigationControllerDelegate
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
