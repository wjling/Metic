//
//  UserInfoViewController.m
//  Metic
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserInfoViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController
@synthesize banner_UIview;
@synthesize banner_imageView;
@synthesize avatar_imageView;
@synthesize name_label;
@synthesize gender_imageView;
@synthesize email_label;
@synthesize info_tableView;

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

@end
