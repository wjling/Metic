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

@interface MenuViewController : UIViewController <UITableViewDelegate,CloudOperationDelegate,PhotoGetterDelegate>

@property (nonatomic, strong) NSString *cellIdentifier;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *email;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end
