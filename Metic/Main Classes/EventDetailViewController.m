
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
@property(nonatomic,strong) NSMutableArray *comment_list;
@property(nonatomic,strong) NSNumber *master_sequence;
@property(nonatomic,strong) NSMutableArray *commentIds;
@property long mainCommentId;
@property BOOL isOpen;
@property BOOL isKeyBoard;




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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.commentIds = [[NSMutableArray alloc]init];
    self.mainCommentId = 0;
    self.sql = [[MySqlite alloc]init];
    self.master_sequence = [NSNumber numberWithInt:0];
    self.isOpen = NO;
    self.isKeyBoard = NO;
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
                self.inputField.text = @"";
                [self.inputField resignFirstResponder];
                [self pullMainCommentFromAir];
                
                
            }
            
        }
            break;
    }
}





- (void)addComment
{
    self.mainCommentId = 0;
    self.isOpen = YES;
    [self.commentView setHidden:NO];
    [self.comment_button setEnabled:NO];
    [self.view bringSubviewToFront:self.commentView];
    
}

- (IBAction)publishComment:(id)sender {
    NSString *comment = ((UITextField*)[self.inputField viewWithTag:1]).text;
    NSLog(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[NSNumber numberWithLong:self.mainCommentId] forKey:@"master"];
    
    
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isKeyBoard) {
        [self.inputField resignFirstResponder];
        return;
    }
    
    if (indexPath.section > 0 && indexPath.row == 0) {
        if (!self.isOpen) {
            [self addComment];
        }
        self.mainCommentId = ([self.commentIds[indexPath.section - 1] longValue]);
        //NSLog(@"%ld",self.mainCommentId);
        
    }
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
        
        
        self.comment_button = cell.comment;
        [self.comment_button addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
        
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

        [self.commentIds setObject:[mainCom valueForKey:@"comment_id"] atIndexedSubscript:indexPath.section-1];
        
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
        cell.commentid = [subCom valueForKey:@"comment_id"];
        cell.controller = self;
        if (![[subCom valueForKey:@"author"] isEqualToString:[MTUser sharedInstance].name]) {
            [((UIButton*)[cell viewWithTag:2]) setHidden:YES];
        }
        else{
            [((UIButton*)[cell viewWithTag:2]) setHidden:NO];
        }
        return cell;
    }
    
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 380.0f;
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


#pragma mark - TextField view delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
    self.inputField.text = @"";
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - Scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isOpen && !self.isKeyBoard) {
        [self.commentView setHidden:YES];
        [self.comment_button setEnabled:YES];
        [self.view sendSubviewToBack:self.commentView];
        self.isOpen = NO;
    }
}
@end
