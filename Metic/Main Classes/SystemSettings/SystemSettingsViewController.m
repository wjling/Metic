//
//  SystemSettingsViewController.m
//  Metic
//
//  Created by mac on 14-7-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SystemSettingsViewController.h"
#import "../../Source/security/SFHFKeychainUtils.h"

@interface SystemSettingsViewController ()

@end

@implementation SystemSettingsViewController
{
    NSInteger numOfSections;
    NSNumber *statusOfSwitch1,*statusOfSwitch2;
    UITapGestureRecognizer* backgroundRecognizer;
    UIAlertView* quitAlert;
}
@synthesize settings_tableview;

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
    [CommonUtils addLeftButton:self isFirstPage:YES];
    settings_tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    settings_tableview.delegate = self;
    settings_tableview.dataSource = self;
    numOfSections = 4;
    [self.view addSubview:settings_tableview];
    
    [self initParams];
    
//    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(40, 0, 300, 44)];
//    [view setBackgroundColor:[UIColor yellowColor]];
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    //        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    button.frame = CGRectMake(0, 0, 300, 44);
//    //        button.center = view.center;
//    button.titleLabel.text = @"退出";
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
////    [view addSubview:button];
////    [settings_tableview.tableHeaderView addSubview:view];
//    settings_tableview.tableHeaderView = view;

    
    
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

-(void)initParams
{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]];
    statusOfSwitch1 = [userSettings objectForKey:@"systemSetting1"];
    statusOfSwitch2 = [userSettings objectForKey:@"systemSetting2"];
    
    backgroundRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundClicked)];
//    [self.settings_tableview addGestureRecognizer:backgroundRecognizer];
    
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];
    NSLog(@"touch begin");
    [quitAlert dismissWithClickedButtonIndex:0 animated:YES];
}


-(void)backgroundClicked
{
    NSLog(@"quit alert");
    [quitAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)switch1Clicked:(UISwitch*)sender
{
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    if ([sender isKindOfClass:[UISwitch class]]) {
//        [userDf setBool:sender.on forKey:@"systemSettings1"];
        [userSettings setValue:[NSNumber numberWithBool:sender.on] forKey:@"systemSetting1"];
        [userDf setObject:userSettings forKey:key];
        NSLog(@"switch1: %@",[NSNumber numberWithBool:sender.on]);
    }
    [userDf synchronize];
}

-(void)switch2Clicked:(UISwitch*)sender
{
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    if ([sender isKindOfClass:[UISwitch class]]) {
        [userSettings setValue:[NSNumber numberWithBool:sender.on] forKey:@"systemSetting2"];
        [userDf setObject:userSettings forKey:key];
        NSLog(@"switch2: %@",[NSNumber numberWithBool:sender.on]);;
    }
    [userDf synchronize];
}

-(void)clearBuffers
{
    SDImageCache* cache = [SDImageCache sharedImageCache];
    [cache clearDisk];
    [cache clearMemory];
    NSString* documentPath = [NSString stringWithFormat:@"%@/Documents/media/avatar",NSHomeDirectory()];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:documentPath error:nil];
    [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)updateCheck
{
    
}

-(void)aboutApp
{
    
}

-(void)quit
{
    quitAlert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"请选择退出方式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出程序",@"切换账号", nil];
    [quitAlert show];
    
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([animationID compare:@"exitApplication"] == 0) {
        
        exit(0);
        
    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"退出程序");
        [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Metic被用户残忍杀死了");
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance]) {
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
        [UIView beginAnimations:@"exitApplication" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view.window cache:NO];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        self.view.window.bounds = CGRectMake(0, 0, 0, 0);
        [(SlideNavigationController*)self.navigationController leftMenu].view.hidden = YES;
//        [(AppDelegate*)[UIApplication sharedApplication].delegate window].bounds = CGRectMake(0, 0, 0, 0);
        [UIView commitAnimations];
//        exit(0);
        
    }
    else if (buttonIndex == 2)
    {
        NSLog(@"切换账号");
        ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isLogined = NO;
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) disconnect];
        [[MTUser alloc]init];
        [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    NSLog(@"did present alertview");
//    UIView* view = [alertView superview];
//    if (view) {
//        NSLog(@"add gesture in view ");
//        view.userInteractionEnabled = YES;
//        [view addGestureRecognizer:backgroundRecognizer];
//    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 1;
        }
            break;
        case 2:
        {
            return 3;
        }
            break;
        case 3:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting"];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        cell.textLabel.text = @"通知栏提醒";
        UISwitch* nSwitch1 = [[UISwitch alloc]initWithFrame:CGRectMake(225, 8, 30, 30)];
        [nSwitch1 addTarget:self action:@selector(switch1Clicked:) forControlEvents:UIControlEventValueChanged];
        nSwitch1.on = [statusOfSwitch1 boolValue];
        nSwitch1.tag = 1;
        [cell addSubview:nSwitch1];
    }
    else if(section == 1)
    {
        cell.textLabel.text = @"清空缓存";
    }
    else if(section == 2)
    {
        if (row == 0) {
            cell.textLabel.text = @"版本更新提醒";
            UISwitch* nSwitch2 = [[UISwitch alloc]initWithFrame:CGRectMake(225, 8, 30, 30)];
            [nSwitch2 addTarget:self action:@selector(switch2Clicked:) forControlEvents:UIControlEventValueChanged];
            nSwitch2.on = [statusOfSwitch2 boolValue];
            nSwitch2.tag = 2;
            [cell addSubview:nSwitch2];
        }
        else if (row == 1)
        {
            cell.textLabel.text = @"检测更新";
        }
        else if (row == 2)
        {
            cell.textLabel.text = @"关于活动宝";
        }
    }
    else if (section == 3)
    {
//        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//        [view setBackgroundColor:[UIColor clearColor]];
//         UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 100, 40)];
////        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////        button.frame = CGRectMake(10, 0, 100, 40);
////        button.center = view.center;
//        button.titleLabel.text = @"退出";
//        [button setBackgroundColor:[UIColor yellowColor]];
//        
////        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
////        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
//        
//        [cell addSubview:button];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"退出";
        [cell setBackgroundColor:[UIColor redColor]];
        label.center = cell.center;
        [cell.contentView addSubview:label];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        [cell setHighlighted:YES animated:YES];
    }
    
    return cell;
}

#pragma  mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (numOfSections == section +1) {
//        return 50;
//    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (section == 0) {
        UISwitch* mSwitch = (UISwitch*)[cell viewWithTag:1];
        if ([mSwitch isKindOfClass:[UISwitch class]]) {
            [mSwitch setOn:!mSwitch.on animated:YES];
            [self switch1Clicked:mSwitch];
        }
    }
    else if (section == 1)
    {
        [self clearBuffers];
    }
    else if (section == 2)
    {
        if (row == 0) {
            UISwitch* mSwitch = (UISwitch*)[cell viewWithTag:2];
            if ([mSwitch isKindOfClass:[UISwitch class]]) {
                [mSwitch setOn:!mSwitch.on animated:YES];
                [self switch2Clicked:mSwitch];
            }
        }
        else if (row == 1)
        {
            
        }
        else if (row == 2)
        {
            
        }
    }
    else if (section == 3)
    {
        [self quit];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section == numOfSections - 1) {
//        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 44)];
//        [view setBackgroundColor:[UIColor yellowColor]];
//        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
////        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//        button.frame = CGRectMake(0, 0, 300, 44);
////        button.center = view.center;
//        button.titleLabel.text = @"退出";
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
//        [view addSubview:button];
//        return view;
//    }
//    return nil;
//}

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
//    if (distance > 0) {
//        self.shadowView.hidden = NO;
//        [self.view bringSubviewToFront:self.shadowView];
//        [self.shadowView setAlpha:distance/400.0];
//    }else{
//        self.shadowView.hidden = YES;
//        [self.view sendSubviewToBack:self.shadowView];
//    }
}


@end
