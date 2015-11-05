//
//  ContactsViewController.h
//  WeShare
//
//  Created by 俊健 on 15/11/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ContactsRecommendTableViewCell.h"
#import "CommonUtils.h"
#import "HttpSender.h"
#import "PhotoGetter.h"
#import "AddFriendConfirmViewController.h"

@interface ContactsViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *tabPage1_view;
@property (strong, nonatomic) IBOutlet UIView *noUpload_view;
@property (strong, nonatomic) IBOutlet UIButton *addContacts_button;
@property (strong, nonatomic) IBOutlet UIView *hasUpload_view;
@property (strong, nonatomic) IBOutlet UITableView *contacts_tableview;

@property (strong, nonatomic) NSMutableArray* contacts_arr;
@property (strong, nonatomic) NSMutableArray* contactFriends_arr;
@property (strong, nonatomic) NSMutableArray* phoneNumbers;

@end
