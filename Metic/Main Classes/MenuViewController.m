//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "MenuViewController.h"
#import "FriendsViewController.h"
#import "NotificationsViewController.h"
#import "EventInvitationViewController.h"
#import "EventSquareViewController.h"
#import "UserInfo/UserInfoViewController.h"
#import "ScanViewController.h"
#import "MTUser.h"


@interface MenuViewController ()
{
    NSInteger numberOfMenus;
    NSMutableArray* notificationSigns_arr;
}
@property(nonatomic,strong) UIImageView* testImageView;
@property(nonatomic,strong) UIImage* testImage;
@property(nonatomic,strong) UIImageView* gender;



@end
@implementation MenuViewController
@synthesize homeViewController;
@synthesize eventInvitationViewController;
@synthesize friendsViewController;
@synthesize notificationsViewController;
@synthesize eventSquareViewController;
@synthesize scaningViewController;
@synthesize feedBackViewController;
@synthesize systemSettingsViewController;
@synthesize cellIdentifier;
@synthesize tapRecognizer;

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (![[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        CGRect frame = self.view.frame;
        frame.origin.y = 20;
        [self.view setFrame:frame];
    }
    self.img.layer.masksToBounds = YES;
    [self.img.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.img.layer setBorderWidth:3.0f];
    [self.img.layer setCornerRadius:28];
    
    numberOfMenus = 8;
    notificationSigns_arr = [[NSMutableArray alloc]initWithCapacity:numberOfMenus];
    for (NSInteger i = 0; i < numberOfMenus; i++) {
        notificationSigns_arr[i] = [NSNumber numberWithBool:NO];
    }
    homeViewController = ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"menuviewcontroller will appear");
    NSString *key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSMutableDictionary* userSettings = [[NSUserDefaults standardUserDefaults]valueForKey:key];
    NSNumber* flag = [userSettings valueForKey:@"hasUnreadNotification"];
    NSLog(@"hasUnreadNotification: %@", flag);
    if ([flag integerValue]>= 0) {
        [self showUpdateInRow:4];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.userName.text = [MTUser sharedInstance].name;
    self.email.text = [MTUser sharedInstance].email;
    
    if (!_gender && [MTUser sharedInstance].gender) {
        float userNameLength = [self calculateTextWidth:[MTUser sharedInstance].name height:self.userName.frame.size.height fontSize:18];
        _gender = [[UIImageView alloc]initWithFrame:CGRectMake(userNameLength+_userName.frame.origin.x + 10, 20, 20 , 20)];
        if ([[MTUser sharedInstance].gender intValue] == 1) {
            [self.gender setImage:[UIImage imageNamed:@"男icon"]];
        }else if([[MTUser sharedInstance].gender intValue] == 0) [self.gender setImage:[UIImage imageNamed:@"女icon"]];
        [self.view addSubview:_gender];
        
    }
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.img authorId:[MTUser sharedInstance].userid];
    NSLog(@"menu did appear,  Uid: %@",[MTUser sharedInstance].userid);
    [getter getAvatar];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)refresh
{
    self.userName.text = [MTUser sharedInstance].name;
    self.email.text = [MTUser sharedInstance].email;
    float userNameLength = [self calculateTextWidth:[MTUser sharedInstance].name height:self.userName.frame.size.height fontSize:18];
    if (!_gender) {
        _gender = [[UIImageView alloc]initWithFrame:CGRectMake(userNameLength+_userName.frame.origin.x + 10, 20, 20, 20)];
        [self.view addSubview:_gender];
    }
    _gender.frame = CGRectMake(userNameLength+_userName.frame.origin.x + 10, 20, 20, 20);
    if ([[MTUser sharedInstance].gender intValue] == 1) {
        [self.gender setImage:[UIImage imageNamed:@"男icon"]];
    }else if([[MTUser sharedInstance].gender intValue] == 0) [self.gender setImage:[UIImage imageNamed:@"女icon"]];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.img authorId:[MTUser sharedInstance].userid];
    [_tableView reloadData];
    NSLog(@"menu Uid: %@",[MTUser sharedInstance].userid);
    [getter getAvatar];
    NSLog(@"gender imageView frame: x: %f",_gender.frame.origin.x);
    
//    if ([MTUser sharedInstance].eventRequestMsg.count > 0 ||
//        [MTUser sharedInstance].friendRequestMsg.count > 0 ||
//        [MTUser sharedInstance].systemMsg.count > 0)
//    {
//        notificationSigns_arr[4] = [NSNumber numberWithBool:YES];
//    }
//    else
//    {
//        notificationSigns_arr[4] = [NSNumber numberWithBool:NO];
//    }
}

-(void)clearVC
{
    NSLog(@"homeViewController is cleared ");
    homeViewController = nil;
    eventInvitationViewController = nil;
    friendsViewController = nil;
    notificationsViewController = nil;
    eventSquareViewController = nil;
    scaningViewController = nil;
    feedBackViewController = nil;
    systemSettingsViewController = nil;
    
}

-(float)calculateTextWidth:(NSString*)text height:(float)height fontSize:(float)fsize
{
    float width = 0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    //设置自动行数与字符换行，为0标示无限制
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;//换行方式
    UIFont *font = [UIFont systemFontOfSize:fsize];
    label.font = font;
    
    CGSize size = CGSizeMake(CGFLOAT_MAX,height);//LableWight标签宽度，固定的
    //计算实际frame大小，并将label的frame变成实际大小
    
    CGSize labelsize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:label.lineBreakMode];
    width = labelsize.width;
    return width;
    
}


- (IBAction)selector_tap:(id)sender {
    __block float val = 21.0/255.0;
    UIColor *color = _UserInfoView.backgroundColor;
    [_UserInfoView setBackgroundColor:([UIColor colorWithRed:val green:val blue:val alpha:1.0f])];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_UserInfoView setBackgroundColor:color];
    });
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	UserInfoViewController *vc ;
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
    vc.needPopBack = NO;
    [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];

}

-(void)showUpdateInRow:(NSInteger)row
{
    NSLog(@"显示消息中心红点");
    [notificationSigns_arr replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
    [_tableView reloadData];
}

-(void)hideUpdateInRow:(NSInteger)row
{
    NSLog(@"隐藏消息中心红点");
    [notificationSigns_arr replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:NO]];
    [_tableView reloadData];
}

-(void)showNotificationCenter
{
    NSLog(@"自动跳转到消息中心");
    if (![[SlideNavigationController sharedInstance].topViewController isKindOfClass:[NotificationsViewController class]]) {
        if (!self.notificationsViewController) {
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            self.notificationsViewController = [mainStoryBoard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
            
        }
        [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:self.notificationsViewController withCompletion:nil];
    }
    
}


#pragma mark - UITableView Delegate & Datasrouce -

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    float val = 21.0/255.0;
    [cell setBackgroundColor:[UIColor colorWithRed:val green:val blue:val alpha:1.0f]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell setBackgroundColor:[UIColor clearColor]];});
}

//-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [cell setBackgroundColor:[UIColor clearColor]];
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return numberOfMenus;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
	switch (indexPath.row)
	{
		case 0:
            
			((UILabel*)[cell viewWithTag:2]).text = @"我的活动";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标1"]];
			break;
			
		case 1:
			((UILabel*)[cell viewWithTag:2]).text = @"活动邀请";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标2"]];
			break;
			
        case 2:
			((UILabel*)[cell viewWithTag:2]).text = @"活动广场";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标7"]];
			break;

		case 3:
			((UILabel*)[cell viewWithTag:2]).text = @"好友中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标3"]];
			break;
        case 4:
			((UILabel*)[cell viewWithTag:2]).text = @"消息中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标6"]];
			break;
        case 5:
			((UILabel*)[cell viewWithTag:2]).text = @"扫一扫";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标8"]];
			break;
        case 6:
			((UILabel*)[cell viewWithTag:2]).text = @"意见反馈";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标9"]];
			break;
        case 7:
			((UILabel*)[cell viewWithTag:2]).text = @"系统设置";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标4"]];
			break;

            
	}
    
    UIImageView* dian = (UIImageView*)[cell viewWithTag:88];
    if (!dian) {
        UILabel* label = (UILabel*)[cell viewWithTag:2];
        NSString* text = label.text;
        UIFont* font = label.font;
        CGSize sizeOfText = [text sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 25) lineBreakMode:NSLineBreakByWordWrapping];
        dian = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"选择点图标.png"]];
        dian.tag = 88;
//        [dian setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"选择点图标.png"]]];
        dian.frame = CGRectMake(label.frame.origin.x + sizeOfText.width + 5, label.frame.origin.y, 10, 10);
        [cell addSubview:dian];
    }
    BOOL flag = [[notificationSigns_arr objectAtIndex:indexPath.row] boolValue];
    if (flag) {
        dian.hidden = NO;
    }
    else
    {
        dian.hidden = YES;
    }

    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	UIViewController *vc ;
	
	switch (indexPath.row)
	{
		case 0:
            if (!homeViewController) {
//                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
//                _homeViewController = vc;
                NSLog(@"homeViewController is nil");
                homeViewController = ((AppDelegate*)[UIApplication sharedApplication].delegate).homeViewController;
                if (!homeViewController) {
                    homeViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
                }
                vc = homeViewController;
            }else vc = homeViewController;
			break;
			
		case 1:
            if (!eventInvitationViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventInvitationViewController"];
                eventInvitationViewController = vc;
            }else vc = eventInvitationViewController;
			break;
			
        case 2:
            if (!eventSquareViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventSquareViewController"];
                eventSquareViewController = vc;
            }else vc = eventSquareViewController;
			break;
		case 3:
            if (!friendsViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendsViewController"];
                friendsViewController = vc;
            }else vc = friendsViewController;
			break;
			
//		case 2:
//            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
//			break;
            
        case 4:
            if (!notificationsViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
                notificationsViewController = (NotificationsViewController*)vc;
            }else vc = notificationsViewController;
			break;
        
        case 5:
            if (!scaningViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ScaningViewController"];
                ((ScanViewController*)vc).menu = self;
                scaningViewController = vc;
            }else vc = scaningViewController;
			break;
        case 6:
            if (!feedBackViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FeedBackViewController"];
                feedBackViewController = vc;
            }else vc = feedBackViewController;
			break;
        case 7:
        {
            if (!systemSettingsViewController) {
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SystemSettingsViewController"];
                systemSettingsViewController = vc;
            }else vc = systemSettingsViewController;
        }
            break;

        default:
            return;
            
	}
    [self hideUpdateInRow:4];
	[[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}


@end
