//
//  SecurityCenterViewController.m
//  WeShare
//
//  Created by mac on 14-9-1.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SecurityCenterViewController.h"
#import "BindingPhoneViewController.h"
#import "BOAlertController.h"
#import "MTUser.h"

@interface SecurityCenterViewController ()
@property (nonatomic,strong) UITableView *security_tableview;
@end

@implementation SecurityCenterViewController

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
    self.security_tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [self.view addSubview:self.security_tableview];
    self.security_tableview.delegate = self;
    self.security_tableview.dataSource = self;
    self.security_tableview.scrollEnabled = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.security_tableview reloadData];
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
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            MTUser *user = [MTUser sharedInstance];
            if (user.email.length || user.phone.length) {
                [self performSegueWithIdentifier:@"securitycenter_modifypassword" sender:self];
            }else {
                BOAlertController *alert = [[BOAlertController alloc] initWithTitle:@"温馨提示" message:@"暂时无法修改密码，请先绑定手机号" viewController:self];
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
                    
                }];
                [alert addButton:cancelItem type:RIButtonItemType_Cancel];
                
                RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
                    [self performSegueWithIdentifier:@"securitycenter_modifyphon" sender:self];
                }];
                [alert addButton:okItem type:RIButtonItemType_Other];
                [alert show];
            }
        }
            break;
        case 1:
        {
            [self performSegueWithIdentifier:@"securitycenter_modifyphon" sender:self];
        }
            break;
            
        default:
            break;
    }}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"securitycell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"securitycell"];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"修改密码";
            
        }
            break;
        case 1:
        {
            MTUser *user = [MTUser sharedInstance];
            if (user.phone.length) {
                cell.textLabel.text = @"更换绑定手机";
            } else {
                cell.textLabel.text = @"绑定手机";
            }
        }
            break;
            
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
