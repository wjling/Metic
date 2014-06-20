
//
//  EventDetailViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventDetailViewController.h"
#import "MTUser.h"
#import "../Cell/CustomCellTableViewCell.h"
#import "../Cell/MCommentTableViewCell.h"
#import "../Cell/SCommentTableViewCell.h"
#import "../Cell/EventCellTableViewCell.h"


@interface EventDetailViewController ()
@property(nonatomic,strong) NSDictionary *event;
@property(nonatomic,strong) NSNumber *master_sequence;
@property(nonatomic,strong) NSMutableArray *comment_list;
@property BOOL isOpen;

#define downmove 45
#define commentposistion 360
#define scrollViewHeight 720
#define originalHeight 25.0f
#define newHeight 85.0f


//@property(nonatomic) int cellcount;

@end

@implementation EventDetailViewController
{
    NSMutableDictionary *dicClicked;
    CGFloat mHeight;
    NSInteger sectionIndex;
    //int main_Comment_count = 0;
}


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
    self.sql = [[MySqlite alloc]init];
    self.master_sequence = [NSNumber numberWithInt:0];
    self.isOpen = NO;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView.layer setBorderColor:[[UIColor redColor]CGColor]];
    [self.tableView.layer setBorderWidth:2];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self pullEventFromDB];
    [self pullMainCommentFromAir];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{

    
}


#pragma mark - 数据库操作
- (void)updateEventToDB
{

}
- (void)pullMainCommentFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithInt:0] forKey:@"master"];
    [dictionary setValue:self.master_sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_COMMENTS];
}

- (void)pullEventFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_info", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.eventId],@"event_id", nil];
    NSMutableArray *result = [self.sql queryTable:@"event" withSelect:seletes andWhere:wheres];
    if (result.count) {
        NSString *tmpa = [result[0] valueForKey:@"event_info"];
        NSData *tmpb = [tmpa dataUsingEncoding:NSUTF8StringEncoding];
        self.event =  [NSJSONSerialization JSONObjectWithData:tmpb options:NSJSONReadingMutableLeaves error:nil];
    }
    [self.sql closeMyDB];
    
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"comment_list"]) {
                self.comment_list = [response1 valueForKey:@"comment_list"];
                [self.tableView reloadData];
                //[self initCommentView];
            }else
            {
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"评论发布成功" WithDelegate:self WithCancelTitle:@"确定"];
                ((UITextField*)[self.myComment viewWithTag:1]).text = @"";
                [self pullMainCommentFromAir];
                
                
            }
            
        }
            break;
    }
}





- (void)addComment
{
    [self.comment_button setEnabled:NO];
    if (self.myComment) {
        self.isOpen = YES;
        [self.myComment setHidden:NO];
        [self.tableView reloadData];
        [self.myComment setHidden:NO];
        ((UITextField*)[self.myComment viewWithTag:1]).delegate = self;
        [((UIButton*)[self.myComment viewWithTag:2]) addTarget:self action:@selector(publishComment) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

-(void)publishComment
{
    NSString *comment = ((UITextField*)[self.myComment viewWithTag:1]).text;
    NSLog(comment,nil);
    self.isOpen = NO;
    [self.myComment setHidden:YES];
    [self.comment_button setEnabled:YES];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:((UITextField*)[self.myComment viewWithTag:1]).text forKey:@"content"];
    [dictionary setValue:[NSNumber numberWithInt:0] forKey:@"master"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_COMMENT];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.tableView.contentOffset = CGPointMake(0, textField.superview.frame.origin.y - 115);
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.comment_list.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    NSMutableArray *comments = self.comment_list[section - 1];
    return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eventCellIdentifier = @"eventcell";
    static NSString *mCellIdentifier = @"McommentCell";
    static NSString *sCellIdentifier = @"ScommentCell";
    
    
    if (indexPath.section == 0) {
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventCellTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:eventCellIdentifier];
            nibsRegistered = YES;
        }
        EventCellTableViewCell *cell = (EventCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
        
        cell.eventName.text = [_event valueForKey:@"subject"];
        cell.beginTime.text = [_event valueForKey:@"time"];
        cell.endTime.text = [_event valueForKey:@"endTime"];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[_event valueForKey:@"location"] ];
        
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %@ 人参加",(NSNumber*)[_event valueForKey:@"member_count"]];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[_event valueForKey:@"launcher"] ];
        cell.eventDetail.text = [[NSString alloc]initWithFormat:@"%@\n \n \n \n \n",[_event valueForKey:@"remark"]];
        cell.eventId = [_event valueForKey:@"event_id"];
        
        self.myComment = cell.commentInputView;
        
        self.comment_button = cell.comment;
        [self.comment_button addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
        self.myComment = cell.commentInputView;
        [((UIButton*)[self.myComment viewWithTag:2]) addTarget:self action:@selector(publishComment) forControlEvents:UIControlEventTouchUpInside];
        self.isOpen = NO;

        return cell;
    }
    else if (indexPath.row == 0) {
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([MCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:mCellIdentifier];
            nibsRegistered = YES;
        }
        MCommentTableViewCell *cell = (MCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:mCellIdentifier];
        
        NSDictionary *mainCom = self.comment_list[indexPath.section - 1][0];
        [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageNamed:@"default_avatar.jpg"]];
        ((UILabel*)[cell viewWithTag:2]).text = [mainCom valueForKey:@"author"];
        ((UILabel*)[cell viewWithTag:3]).text = [mainCom valueForKey:@"time"];
        ((UILabel*)[cell viewWithTag:4]).text = [NSString stringWithFormat:@"%@\n \n \n \n",[mainCom valueForKey:@"content"]];
        cell.commentid = [mainCom valueForKey:@"comment_id"];
        cell.controller = self;
        if (![[mainCom valueForKey:@"author"] isEqualToString:[MTUser sharedInstance].name]) {
            [((UIButton*)[cell viewWithTag:5]) setHidden:YES];
        }
        else{
            [((UIButton*)[cell viewWithTag:5]) setHidden:NO];
        }
        return cell;
    }
    else
    {
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([SCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:sCellIdentifier];
            nibsRegistered = YES;
        }
        SCommentTableViewCell *cell = (SCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
        NSDictionary *subCom = self.comment_list[indexPath.section - 1][indexPath.row];
        ((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@ : %@", [subCom valueForKey:@"author"], [subCom valueForKey:@"content"]];
        if (![[subCom valueForKey:@"author"] isEqualToString:[MTUser sharedInstance].name]) {
            [((UIButton*)[cell viewWithTag:5]) setHidden:YES];
        }
        return cell;
    }
    
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.isOpen? 440.0f:380.0f;
    }
    else if (indexPath.row == 0) {
        return 95.0f;

    }else
    {
        NSMutableArray *comments = self.comment_list[indexPath.section - 1];
        if (indexPath.row == comments.count - 1) {
            return 35.0f;
        }
        return 21.0f;
    }
}


@end
