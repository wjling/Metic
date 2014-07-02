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
#import "MTUser.h"


@interface MenuViewController ()

@end
@implementation MenuViewController
@synthesize cellIdentifier;
-(void)viewDidLoad
{
    self.userName.text = [MTUser sharedInstance].name;
    self.email.text = [MTUser sharedInstance].email;
    
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.img path:[NSString stringWithFormat:@"/avatar/%@.jpg",[MTUser sharedInstance].userid] type:1 cache:[MTUser sharedInstance].avatar];
    [getter setTypeOption1:[UIColor whiteColor] borderWidth:10];
    getter.mDelegate = self;
    [getter getPhoto];
    
}


#pragma mark - UITableView Delegate & Datasrouce -

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    float val = 21.0/255.0;
    [cell setBackgroundColor:[UIColor colorWithRed:val green:val blue:val alpha:1.0f]];
    NSLog(@"aaa");
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    NSLog(@"ccc");
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 8;
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
			((UILabel*)[cell viewWithTag:2]).text = @"好友中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标3"]];
			break;
			
		case 3:
			((UILabel*)[cell viewWithTag:2]).text = @"系统设置";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标4"]];
			break;
        case 4:
			((UILabel*)[cell viewWithTag:2]).text = @"朋友分享";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标5"]];
			break;
        case 5:
			((UILabel*)[cell viewWithTag:2]).text = @"消息中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标6"]];
			break;
        case 6:
			((UILabel*)[cell viewWithTag:2]).text = @"活动广场";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标7"]];
			break;
        case 7:
			((UILabel*)[cell viewWithTag:2]).text = @"扫一扫";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标8"]];
			break;
	}
    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
			break;
			
		case 1:
			
            return;
			break;
			
		case 2:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendsViewController"];
			break;
			
		case 3:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
			break;
            
        case 5:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
			break;

        default:
            return;
            
	}
	
	[[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    imageView.image = image;
}
@end
