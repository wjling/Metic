//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "MenuViewController.h"
#import "FriendsViewController.h"
#import "MTUser.h"

@interface MenuViewController ()

@end
@implementation MenuViewController
@synthesize cellIdentifier;

-(void)viewWillAppear:(BOOL)animated
{
    self.userName.text = [MTUser sharedInstance].name;
    self.email.text = [MTUser sharedInstance].email;
    [self.img setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
}


#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
	switch (indexPath.row)
	{
		case 0:
            
			((UILabel*)[cell viewWithTag:2]).text = @"活动中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
			
		case 1:
			((UILabel*)[cell viewWithTag:2]).text = @"有关活动";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
			
		case 2:
			((UILabel*)[cell viewWithTag:2]).text = @"好友中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
			
		case 3:
			((UILabel*)[cell viewWithTag:2]).text = @"系统设置";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 4:
			((UILabel*)[cell viewWithTag:2]).text = @"热门推荐";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 5:
			((UILabel*)[cell viewWithTag:2]).text = @"朋友分享";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 6:
			((UILabel*)[cell viewWithTag:2]).text = @"消息中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 7:
			((UILabel*)[cell viewWithTag:2]).text = @"活动广场";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 8:
			((UILabel*)[cell viewWithTag:2]).text = @"扫一扫";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
        case 9:
			((UILabel*)[cell viewWithTag:2]).text = @"退出";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
			break;
	}
    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 37;
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
            
        case 9:
			[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
			return;
			break;
        default:
            return;
            
	}
	
	[[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}

@end
