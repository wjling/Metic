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
@property(nonatomic,strong) UIImageView* testImageView;
@property(nonatomic,strong) UIImage* testImage;
@property(nonatomic,strong) UIImageView* gender;

@end
@implementation MenuViewController
@synthesize cellIdentifier;
@synthesize tapRecognizer;

-(void)viewDidLoad
{
}


-(void)viewWillAppear:(BOOL)animated
{
    self.userName.text = [MTUser sharedInstance].name;
    self.email.text = [MTUser sharedInstance].email;
    self.img.layer.masksToBounds = YES;
    [self.img.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.img.layer setBorderWidth:3.0f];
    [self.img.layer setCornerRadius:33];
    if (!_gender && [MTUser sharedInstance].gender) {
        float userNameLength = [self calculateTextWidth:[MTUser sharedInstance].name height:self.userName.frame.size.height fontSize:21];
        _gender = [[UIImageView alloc]initWithFrame:CGRectMake(userNameLength+_userName.frame.origin.x + 5, 36, 25, 25)];
        if ([[MTUser sharedInstance].gender intValue] == 1) {
            [self.gender setImage:[UIImage imageNamed:@"男icon"]];
        }else if([[MTUser sharedInstance].gender intValue] == 0) [self.gender setImage:[UIImage imageNamed:@"女icon"]];
        [self.view addSubview:_gender];

    }
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.img authorId:[MTUser sharedInstance].userid];
    [getter getPhoto];
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
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	UIViewController *vc ;
    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
    
    [[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];

}


#pragma mark - UITableView Delegate & Datasrouce -

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    float val = 21.0/255.0;
    [cell setBackgroundColor:[UIColor colorWithRed:val green:val blue:val alpha:1.0f]];
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
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
			
//		case 1:
//			((UILabel*)[cell viewWithTag:2]).text = @"活动邀请";
//            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标2"]];
//			break;
			
		case 1:
			((UILabel*)[cell viewWithTag:2]).text = @"好友中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标3"]];
			break;
			
//		case 3:
//			((UILabel*)[cell viewWithTag:2]).text = @"系统设置";
//            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标4"]];
//			break;
//        case 4:
//			((UILabel*)[cell viewWithTag:2]).text = @"朋友分享";
//            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标5"]];
//			break;
        case 2:
			((UILabel*)[cell viewWithTag:2]).text = @"消息中心";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标6"]];
			break;
//        case 6:
//			((UILabel*)[cell viewWithTag:2]).text = @"活动广场";
//            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标7"]];
//			break;
        case 3:
			((UILabel*)[cell viewWithTag:2]).text = @"扫一扫";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标8"]];
			break;
        case 4:
			((UILabel*)[cell viewWithTag:2]).text = @"意见反馈";
            [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"icon图标9"]];
			break;
            
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
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
			break;
			
//		case 1:
//			
//            return;
//			break;
			
		case 1:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendsViewController"];
			break;
			
//		case 2:
//            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfileViewController"];
//			break;
            
        case 2:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
			break;
        case 3:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ScaningViewController"];
			break;
        case 4:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"FeedBackViewController"];
			break;

        default:
            return;
            
	}
	
	[[SlideNavigationController sharedInstance] switchToViewController:vc withCompletion:nil];
}


@end
