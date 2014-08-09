//
//  MenuViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "PhotoGetter.h"
#import "../Utils/CloudOperation.h"

@interface MenuViewController : UIViewController <UITableViewDelegate,CloudOperationDelegate>

@property (nonatomic, strong) NSString *cellIdentifier;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *email;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) UIViewController* homeViewController;
@property(nonatomic,strong) UIViewController* eventInvitationViewController;
@property(nonatomic,strong) UIViewController* friendsViewController;
@property(nonatomic,strong) UIViewController* notificationsViewController;
@property(nonatomic,strong) UIViewController* scaningViewController;
@property(nonatomic,strong) UIViewController* feedBackViewController;
@property(nonatomic,strong) UIViewController* systemSettingsViewController;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;

- (IBAction)selector_tap:(id)sender;
-(void)refresh;
-(void)clearVC;

@end
