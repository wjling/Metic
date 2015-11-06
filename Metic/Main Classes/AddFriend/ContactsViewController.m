//
//  ContactsViewController.m
//  WeShare
//
//  Created by 俊健 on 15/11/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "ContactsViewController.h"
#import "FriendInfoViewController.h"
#import "SVProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import "ContactsRecommendTableViewCell.h"
#import "CommonUtils.h"
#import "HttpSender.h"
#import "PhotoGetter.h"
#import "AddFriendConfirmViewController.h"

@interface ContactsViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *tabPage1_view;
@property (strong, nonatomic) IBOutlet UIView *noUpload_view;
@property (strong, nonatomic) IBOutlet UIButton *addContacts_button;
@property (strong, nonatomic) IBOutlet UIView *hasUpload_view;
@property (strong, nonatomic) IBOutlet UITableView *contacts_tableview;

@property (strong, nonatomic) NSMutableArray* contacts_arr;
@property (strong, nonatomic) NSMutableArray* contactFriends_arr;
@property (strong, nonatomic) NSMutableArray* phoneNumbers;

@end

@implementation ContactsViewController
{
    NSNumber* selectedFriendID;
}

@synthesize tabPage1_view;
@synthesize noUpload_view;
@synthesize addContacts_button;
@synthesize hasUpload_view;
@synthesize contacts_tableview;

@synthesize contacts_arr;
@synthesize contactFriends_arr;
@synthesize phoneNumbers;

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    contacts_arr = [[NSMutableArray alloc] init];
    contactFriends_arr = [[NSMutableArray alloc] init];
    
    contacts_tableview.delegate = self;
    contacts_tableview.dataSource = self;
    
    [self initContentView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MTLOG(@"friend recommendation view will appear");
    
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]]];
    NSString* userPhoneNumber = [userSettings objectForKey:@"userPhoneNumber"];
    if (!userPhoneNumber || [userPhoneNumber isEqualToString:@""]) {
        self.noUpload_view.hidden = NO;
        self.hasUpload_view.hidden = YES;
    }
    else
    {
        self.noUpload_view.hidden = YES;
        self.hasUpload_view.hidden = NO;
        [self getContactFriends];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"friendRecommend_addFriend"]) {
        AddFriendConfirmViewController* vc = segue.destinationViewController;
        vc.fid = selectedFriendID;
    }
}

#pragma mark - Private Method

-(void)initContentView
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];

    [self.addContacts_button addTarget:self action:@selector(uploadContacts:) forControlEvents:UIControlEventTouchUpInside];
    self.contacts_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabPage1_view setBackgroundColor:bgColor];
    [self.contacts_tableview setBackgroundColor:bgColor];
}

- (void)getPeopleInContact
{
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    
    if (addressBook == nil) {
        return;
    }
    contacts_arr = (__bridge NSMutableArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
}

- (NSMutableArray*)getFriendsPhoneNumber
{
    NSMutableArray* tels = [[NSMutableArray alloc]init];
    if (contacts_arr) {
        for (int j = 0; j < contacts_arr.count; j++) {
            id tmpPerson = [contacts_arr objectAtIndex:j];
            ABMultiValueRef phones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for (NSInteger i = 0; i < ABMultiValueGetCount(phones); i++) {
                NSMutableString* phoneNumber = (__bridge NSMutableString *)(ABMultiValueCopyValueAtIndex(phones, i));
                [tels addObject:[phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            }
        }
    }
    return tels;
}

-(void)addFriendBtnClicked:(UIButton*)sender
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    AddFriendConfirmViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddFriendConfirmViewController"];
    vc.fid = [NSNumber numberWithInteger:sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)uploadContacts:(id)sender
{
    [self getPeopleInContact];
    phoneNumbers = [self getFriendsPhoneNumber];
    MTLOG(@"phone numbers: %@", phoneNumbers);
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    MTLOG(@"address book authorization status: %ld",status);
    if (status == kABAuthorizationStatusDenied) {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您曾经拒绝了活动宝的通讯录访问，请您在\n设置->隐私->通讯录\n里面授权活动宝获取您的通讯录内容" WithDelegate:self WithCancelTitle:@"确定"];
    } else {
        UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"请绑定您的手机号码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertview.delegate = self;
        alertview.tag = 119;
        [alertview show];
    }
}

-(void)getContactFriends
{
    [self getPeopleInContact];
    phoneNumbers = [self getFriendsPhoneNumber];
    MTLOG(@"phone numbers: %@", phoneNumbers);
    __block BOOL isFinish = NO;
    void (^getContactFriendsDone)(NSData*) = ^(NSData* rData)
    {
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            MTLOG(@"获取通讯录好友，收到的rData为空");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
            return;
        }
        MTLOG(@"get contactfriends done, received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber* cmd = [response1 objectForKey:@"cmd"];
        if ([cmd integerValue] == 100) {
            contactFriends_arr = [response1 objectForKey:@"friend_recom"];
            MTLOG(@"contact friend array: %@",contactFriends_arr);
            if (contactFriends_arr) {
                [contacts_tableview reloadData];
            }
        }
        [SVProgressHUD dismiss];
        isFinish = YES;
    };
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              phoneNumbers,@"friends_phone",nil];
    MTLOG(@"upload number json: %@",json_dic);
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:getContactFriendsDone];
    MTLOG(@"doing getContactFriends, json: %@",json_dic);
    [SVProgressHUD showWithStatus:@"请稍候"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isFinish) {
            [SVProgressHUD dismiss];
        }
    });
}

-(void)dismissAlert:(NSTimer*)timer
{
    UIAlertView* alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.contacts_tableview) {
        return contactFriends_arr.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* bgColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    //    UIColor* seperatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
    
    if (tableView == contacts_tableview) {
        ContactsRecommendTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsRecommendTableViewCell" forIndexPath:indexPath];
        if (nil == cell) {
            cell = [[ContactsRecommendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactsRecommendTableViewCell"];
            
        }
        NSMutableDictionary* friend = [contactFriends_arr objectAtIndex:indexPath.row];
        MTLOG(@"a contact friend: %@",friend);
        NSNumber* fid = [friend valueForKey:@"id"];
        NSString* fname = [friend valueForKey:@"name"];
        NSNumber* isFriend = [friend valueForKey:@"isFriend"];
        MTLOG(@"isFriend: %d",[isFriend boolValue]);
        PhotoGetter* getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:fid];
        [getter getAvatar];
        cell.name_label.text = fname;
        if ([isFriend boolValue]) {
            cell.add_button.hidden = YES;
            cell.invite_button.hidden = YES;
            cell.hasAdd_label.hidden = NO;
        }
        else
        {
            cell.add_button.hidden = NO;
            cell.invite_button.hidden = YES;
            cell.hasAdd_label.hidden = YES;
        }
        
        cell.add_button.tag = [fid integerValue];
        [cell.add_button addTarget:self action:@selector(addFriendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setBackgroundColor:bgColor];
        UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        cell.layer.borderColor = borderColor.CGColor;
        cell.layer.borderWidth = 0.3;
        return cell;
        
    }
    return nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 119) {
        if (buttonIndex == 0) //cancel button
        {
            
        }
        else if (buttonIndex == 1)
        {
            NSString* phone = [alertView textFieldAtIndex:0].text;
            if ([phone isEqualToString:@""]) {
                [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"您不可以绑定一个空号哦" WithDelegate:self WithCancelTitle:@"确定"];
            }
            else
            {
                NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
                NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
                NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
                [userSettings setValue:phone forKey:@"userPhoneNumber"];
                [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"hasUploadPhoneNumber"];
                [userDf setObject:userSettings forKey:key];
                [userDf synchronize];
                MTLOG(@"user settings : %@",userSettings);
                
                void (^uploadContactsDone)(NSData*) = ^(NSData* rData)
                {
                    NSString* temp;
                    if (rData)
                    {
                        temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                    }
                    else
                    {
                        MTLOG(@"上传通讯录，收到的rData为空");
                        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"服务器未响应，有可能是网络未连接" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                        [alertView show];
                        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissAlert:) userInfo:alertView repeats:NO];
                        return;
                    }
                    MTLOG(@"upload contact done, received Data: %@",temp);
                    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                    NSNumber* cmd = [response1 objectForKey:@"cmd"];
                    if ([cmd integerValue] == 100)
                    {
                        contactFriends_arr = [response1 objectForKey:@"friend_recom"];
                        [contacts_tableview reloadData];
                    }
                    
                };
                NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:
                                         [MTUser sharedInstance].userid, @"id",
                                         phone, @"my_phone_number",
                                         phoneNumbers, @"friends_phone",nil];
                MTLOG(@"upload number json: %@",jsonDic);
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
                HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
                [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:uploadContactsDone];
                self.noUpload_view.hidden = YES;
                self.hasUpload_view.hidden = NO;
            }
        }
    }
}


@end
