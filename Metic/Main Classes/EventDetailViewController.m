
//
//  EventDetailViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Event2DcodeViewController.h"
#import "MTUser.h"
#import "PictureWallViewController.h"
#import "Report/ReportViewController.h"
#import "../Cell/CustomCellTableViewCell.h"
#import "../Cell/MCommentTableViewCell.h"
#import "../Cell/SCommentTableViewCell.h"
#import "../Cell/EventCellTableViewCell.h"
#import "showParticipatorsViewController.h"
#import "../Source/MLEmoji/MLEmojiLabel.h"
#import "NSString+JSON.h"
#import "emotion_Keyboard.h"
#import "MobClick.h"

#define MainFontSize 14
#define MainCFontSize 13
#define SubCFontSize 12

@interface EventDetailViewController ()<UITextViewDelegate>
@property(nonatomic,strong) NSMutableArray *comment_list;
@property(nonatomic,strong) NSMutableArray *commentIds;
@property(nonatomic,strong) UIAlertView *Alert;
@property(nonatomic,strong) NSNumber* repliedId;
@property (strong, nonatomic) IBOutlet emotion_Keyboard *emotionKeyboard;

@property(nonatomic,strong) NSString* herName;
@property(nonatomic,strong) UIView* shadowView;

@property BOOL visibility;
@property BOOL isMine;
@property long mainCommentId;
@property long Selete_section;
@property BOOL isOpen;
@property BOOL Headeropen;
@property BOOL Footeropen;



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
    [self initUI];

    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.commentIds = [[NSMutableArray alloc]init];
    self.comment_list = [[NSMutableArray alloc]init];
    self.mainCommentId = 0;
    self.Headeropen = NO;
    self.Footeropen = NO;
    self.sql = [[MySqlite alloc]init];
    self.master_sequence = [NSNumber numberWithInt:0];
    self.isOpen = NO;
    self.isEmotionOpen = NO;
    self.isKeyBoard = NO;
    _inputTextView.delegate = self;
    _emotionKeyboard.textView = _inputTextView;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.inputTextView.placeHolder = @"回复楼主";
    [self.view bringSubviewToFront:self.commentView];
    [self.view bringSubviewToFront:self.emotionKeyboard];
    [self pullEventFromDB];
    [self pullMainCommentFromAir];
    
    _header = [[MJRefreshHeaderView alloc]init];
    _header.delegate = self;
    _header.scrollView = self.tableView;
    
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = self.tableView;

    [_emotionKeyboard initCollectionView];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [_optionView setHidden:YES];
    if (_shadowView) [_shadowView removeFromSuperview];
    [self pullEventFromAir];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedExt:) name:UITextViewTextDidChangeNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"活动详情"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"活动详情"];
    [self.inputTextView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

-(void)dealloc
{
    
}

-(void)initUI
{
    _moreView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
	_moreView.layer.shadowRadius = 10;
	_moreView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_moreView.bounds].CGPath;
	_moreView.layer.shadowOpacity = 1;

    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    [self.commentView addSubview:textView];
	_inputTextView = textView;

    _inputTextView.frame = CGRectMake(38, 5, 240, 35);
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
   
}

-(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize
{
    UIFont *font = [UIFont systemFontOfSize:fsize];
    CGSize size = CGSizeMake(width,2000);
    CGRect labelRect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    return ceil(labelRect.size.height)*1.25;
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


//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

//点击表情按钮
- (IBAction)button_Emotionpress:(id)sender {
    if (!_emotionKeyboard) {
        _emotionKeyboard = [[emotion_Keyboard alloc]initWithPoint:CGPointMake(0, self.view.frame.size.height - 200)];
        

        
    }
    if (!_isEmotionOpen) {
        _isEmotionOpen = YES;
        if (_isKeyBoard) {
            [_inputTextView resignFirstResponder];
        }
        //[self.view bringSubviewToFront:_emotionKeyboard];
        //[self.view addSubview:_emotionKeyboard];
        CGRect keyboardBounds = _emotionKeyboard.frame;
        // get a rect for the textView frame
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        [_emotionKeyboard setFrame:frame];
        
        // commit animations
        [UIView commitAnimations];
    }else {
        _isEmotionOpen = NO;
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height;
        [_emotionKeyboard setFrame:frame];
        [UIView commitAnimations];
        //[_emotionKeyboard removeFromSuperview];
    }
    
    
}

- (void)pullMainCommentFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:0] forKey:@"master"];
    [dictionary setValue:self.master_sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_COMMENTS];
}

-(void)getmoreComments:(NSNumber*) master sub_Sequence:(NSNumber*)sub_Sequence Scomments:(NSMutableArray*)Scomments
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:master forKey:@"master"];
    [dictionary setValue:sub_Sequence forKey:@"sequence"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_COMMENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                NSMutableArray *comments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"comment_list"]];
                for (int i = 0; i < comments.count; i++) {
                    NSMutableDictionary* comment = [[NSMutableDictionary alloc]initWithDictionary:comments[i]];
                    comments[i] = comment;
                }
                [Scomments addObjectsFromArray:comments];
                [_tableView reloadData];
            }else{
                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            }
        }else{
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
        }

    }];
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

-(void)pullEventFromAir
{
    NSArray* eventids = @[_eventId];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:eventids forKey:@"sequence"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENTS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
            self.event = [response1 valueForKey:@"event_list"][0];
            if(_event)[self updateEventToDB:_event];
            [_tableView reloadData];
        }
        
    }];
}

- (void)updateEventToDB:(NSDictionary*)event
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    NSString *eventData = [NSString jsonStringWithDictionary:_event];
    eventData = [eventData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'event_info'", nil];
    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[event valueForKey:@"event_id"]],[NSString stringWithFormat:@"'%@'",eventData], nil];
    
    [self.sql insertToTable:@"event" withColumns:columns andValues:values];
    [self.sql closeMyDB];
}

- (void)addComment
{
    self.mainCommentId = 0;
    self.isOpen = YES;
    [self.commentView setHidden:NO];
    [self.comment_button setEnabled:NO];
    //[self.view bringSubviewToFront:self.commentView];
    
}

- (void)readyforMainC
{
    self.repliedId = nil;
    self.mainCommentId = 0;
}

- (IBAction)more:(id)sender {
    if (_optionView.isHidden) {
        [_optionView setHidden:NO];
        [self.inputTextView resignFirstResponder];
        CGRect frame = self.view.frame;
        frame.origin = CGPointMake(0, 0);
        _shadowView = [[UIView alloc]initWithFrame:frame];
        [self.view addSubview:_shadowView];
        [self.view bringSubviewToFront:_optionView];
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(more:)];
        [_shadowView addGestureRecognizer:tapRecognizer];
    }else{
        [_optionView setHidden:YES];
        if (_shadowView) {
            [_shadowView removeFromSuperview];
            _shadowView = nil;
        }
    }
}


- (void)delete_Comment:(id)sender {
    
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSInteger section = [_tableView indexPathForCell:cell].section;
    NSMutableArray *comments = _comment_list[section-1];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:((MCommentTableViewCell*)cell).commentid forKey:@"comment_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:DELETE_COMMENT finshedBlock:^(NSData *rData) {
        [_comment_list removeObject:comments];
        [_tableView reloadData];
    }];
}

- (void)appreciate:(id)sender {
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSInteger section = [_tableView indexPathForCell:cell].section;
    NSMutableArray *comments = _comment_list[section-1];
    NSMutableDictionary *waitingComment = _comment_list[section-1][0];
    BOOL isZan = [[waitingComment valueForKey:@"isZan"] boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:((MCommentTableViewCell*)cell).commentid forKey:@"comment_id"];
    [dictionary setValue:[NSNumber numberWithInt:isZan? 0:1]  forKey:@"operation"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                [waitingComment setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
                int zan_num = [[waitingComment valueForKey:@"good"] intValue];
                if (isZan) {
                    zan_num --;
                }else{
                    zan_num ++;
                }
                [waitingComment setValue:[NSNumber numberWithInt:zan_num] forKey:@"good"];
                [_tableView reloadData];
            }
//            else{
//                [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
//            }
        }
//        else{
//            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
//        }

    }];
}


-(void)resendComment:(id)sender{
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    
    NSInteger row = [_tableView indexPathForCell:cell].row;
    NSInteger section = [_tableView indexPathForCell:cell].section;
    NSMutableDictionary *waitingComment;
    NSMutableArray *comments = _comment_list[section-1];
    if (row == 0) {
        waitingComment = _comment_list[section-1][0];
    }else{
        waitingComment = _comment_list[section-1][[_comment_list[section-1] count] - row];
    }
    NSString *comment = [waitingComment valueForKey:@"content"];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"comment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[NSNumber numberWithLong:self.mainCommentId] forKey:@"master"];
    if ([waitingComment valueForKey:@"replied"]) {
        [dictionary setValue:[waitingComment valueForKey:@"replied"] forKey:@"replied"];
    }
    

    
    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(waitingComment && [[waitingComment valueForKey:@"comment_id"] intValue]== -1){
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            [_tableView reloadData];
            
        }
    });
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_COMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"comment_id"]) {
                [waitingComment setValue:[response1 valueForKey:@"comment_id"] forKey:@"comment_id"];
                [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                if (row == 0) {
                    [_comment_list removeObject:comments];
                    [_comment_list insertObject:comments atIndex:0];
                }else{
                    [comments removeObject:waitingComment];
                    [comments insertObject:waitingComment atIndex:1];
                }
                [_tableView reloadData];
            }else{
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
                [_tableView reloadData];
            }
        }else{
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            [_tableView reloadData];
        }
    }];

}



- (IBAction)publishComment:(id)sender {
    NSString *comment = _inputTextView.text;
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        _inputTextView.text = @"";
        return;
    }
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    [dictionary setValue:[NSNumber numberWithLong:self.mainCommentId] forKey:@"master"];
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    if (_repliedId && [_repliedId intValue]!=[[MTUser sharedInstance].userid intValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        [newComment setValue:_repliedId forKey:@"replied"];
        comment = [[NSString stringWithFormat:@" 回复 %@ : ",_herName] stringByAppendingString:comment];
    }
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"comment_num"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"comment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"master"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];
    NSMutableArray*newComments;
    switch (_mainCommentId) {
        case 0:{
            
            //加入到评论数组里
            newComments = [[NSMutableArray alloc] initWithObjects:newComment, nil];
            [_comment_list insertObject:newComments atIndex:0];
            
        }
            break;
            
        default:{
            newComments = _comment_list[_Selete_section-1];
            [newComments insertObject:newComment atIndex:1];
        }
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(newComment && [[newComment valueForKey:@"comment_id"] intValue]== -1){
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            [_tableView reloadData];
            
        }
    });

    [_tableView reloadData];
    self.inputTextView.text = @"";
    if (_isKeyBoard) [self.inputTextView resignFirstResponder];
    if (_isEmotionOpen) [self button_Emotionpress:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textChangedExt:nil];
        self.inputTextView.text = @"";
    });
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_COMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"comment_id"]) {
                {
                    [newComment setValue:[response1 valueForKey:@"comment_id"] forKey:@"comment_id"];
                    [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                    if (_mainCommentId == 0) {
                        [_comment_list removeObject:newComments];
                        [_comment_list insertObject:newComments atIndex:0];
                    }else{
                        [newComments removeObject:newComment];
                        [newComments insertObject:newComment atIndex:1];
                    }
                    [_tableView reloadData];
                }
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
                [_tableView reloadData];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"comment_id"];
            [_tableView reloadData];
        }
        

    }];
    
    
}

- (IBAction)show2Dcode:(id)sender {

    [self performSegueWithIdentifier:@"2Dcode" sender:self];
}

- (IBAction)report:(id)sender {

    [self performSegueWithIdentifier:@"EventToReport" sender:self];

}

-(void)closeRJ
{
    if (_Headeropen) {
        _Headeropen = NO;
        [_header endRefreshing];
    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
    [self.tableView reloadData];
}

-(void)showAlert
{
    _Alert = [[UIAlertView alloc] initWithTitle:@"" message:@"没有更多了" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_Alert show];
    self.Footeropen = NO;
    [_footer endRefreshing];
}
-(void)performDismiss
{
    [_Alert dismissWithClickedButtonIndex:0 animated:NO];
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
    if (_Footeropen||_Headeropen) {
        [refreshView endRefreshing];
        return;
    }
    if (refreshView == _header) {
        _Headeropen = YES;
        self.master_sequence = [NSNumber numberWithInt:0];
    }else _Footeropen = YES;
    [self pullMainCommentFromAir];
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
    NSDictionary *mainCom = comments[0];
    int comment_num = [[mainCom valueForKey:@"comment_num"] intValue];
    if (comment_num > comments.count - 1) {
        return comments.count+1;
    }
    
    return comments.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isKeyBoard) {
        [self.inputTextView resignFirstResponder];
        return;
    }
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
        return;
    }
    if (indexPath.section == 0) {
        [self.inputTextView becomeFirstResponder];
        self.inputTextView.placeHolder = @"回复楼主:";
        self.repliedId = nil;
        self.mainCommentId = 0;
    }
    else if (indexPath.row == 0) {
        MCommentTableViewCell *cell = (MCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.commentid intValue] < 0 ) {
            return;
        }
        [self.inputTextView becomeFirstResponder];
        self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",cell.author];
        self.mainCommentId = ([self.commentIds[indexPath.section - 1] longValue]);
        self.Selete_section = indexPath.section;
        self.repliedId = nil;
    }else{
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            NSDictionary* lastSubComment = [comments lastObject];
            [self getmoreComments:[lastSubComment valueForKey:@"master"] sub_Sequence:[lastSubComment valueForKey:@"comment_id"]Scomments:comments];
            return;
        }
        SCommentTableViewCell *cell = (SCommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.commentid intValue] < 0 ) {
            return;
        }
        [self.inputTextView becomeFirstResponder];
        self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",cell.author];
        self.mainCommentId = ([self.commentIds[indexPath.section - 1] longValue]);
        self.repliedId = cell.authorid;
        self.Selete_section = indexPath.section;
        self.herName = cell.author;
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
        NSString* beginT = [_event valueForKey:@"time"];
        NSString* endT = [_event valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[_event valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[_event valueForKey:@"location"] ];
        int participator_count = [[_event valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[_event valueForKey:@"launcher"]];
        _isMine = [[_event valueForKey:@"launcher_id"] intValue] == [[MTUser sharedInstance].userid intValue];
        _visibility = [[_event valueForKey:@"visibility"] boolValue] || _isMine;
        if (_visibility) {
            [cell.addPaticipator setBackgroundImage:[UIImage imageNamed:@"活动邀请好友"] forState:UIControlStateNormal];
        }else [cell.addPaticipator setBackgroundImage:[UIImage imageNamed:@"不能邀请好友"] forState:UIControlStateNormal];
        NSString* text = [_event valueForKey:@"remark"];
        float commentHeight = [self calculateTextHeight:text width:300.0 fontSize:MainCFontSize];
        if (commentHeight < 25) commentHeight = 25;
        cell.eventDetail.text = text;
        CGRect frame = cell.eventDetail.frame;
        frame.size.height = commentHeight;
        [cell.eventDetail setFrame:frame];
        frame = cell.frame;
        frame.size.height = 248 + commentHeight;
        
        cell.eventId = [_event valueForKey:@"event_id"];
        cell.eventController = self;
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:self.eventId];
        [bannerGetter getBanner:[_event valueForKey:@"code"]];

        NSArray *memberids = [_event valueForKey:@"member"];
        for (int i =0; i<4; i++) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            //tmp.layer.masksToBounds = YES;
            [tmp.layer setCornerRadius:5];
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getAvatar];
            }else tmp.image = nil;
            
        }

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
        
        ((UILabel*)[cell viewWithTag:2]).text = [mainCom valueForKey:@"author"];
        ((UILabel*)[cell viewWithTag:3]).text = [mainCom valueForKey:@"time"];
        if([[mainCom valueForKey:@"comment_num"]intValue]==0) [cell.subCommentBG setHidden:YES];
        else [cell.subCommentBG setHidden:NO];
        
        
        MLEmojiLabel *textView = (MLEmojiLabel*)[cell viewWithTag:4];
        NSString* text = [mainCom valueForKey:@"content"];
        cell.origincomment = text;
        float commentHeight = [self calculateTextHeight:text width:280.0 fontSize:MainCFontSize];
        if (commentHeight < 25) commentHeight = 25;
        CGRect frame = textView.frame;
        frame.size.height = commentHeight;
        [textView setFrame:frame];
        
        textView.numberOfLines = 0;
        textView.font = [UIFont systemFontOfSize:MainCFontSize];
        textView.backgroundColor = [UIColor clearColor];
        textView.lineBreakMode = NSLineBreakByCharWrapping;
        textView.isNeedAtAndPoundSign = YES;
        
        textView.emojiText = text;
        
        frame = cell.frame;
        frame.size.height = 60 + commentHeight;
        [cell setFrame:frame];

        
        cell.commentid = [mainCom valueForKey:@"comment_id"];
        cell.eventId = _eventId;
        cell.author = [mainCom valueForKey:@"author"];
        cell.authorId = [mainCom valueForKey:@"author_id"];
        cell.controller = self;
        cell.good_num.text = [NSString stringWithFormat:@"(%d)",[[mainCom valueForKey:@"good"]intValue]];
        cell.isZan = [[mainCom valueForKey:@"isZan"] boolValue];
        if (cell.isZan) {
            [cell.good_button setImage:[UIImage imageNamed:@"实心点赞图"] forState:UIControlStateNormal];
        }else [cell.good_button setImage:[UIImage imageNamed:@"点赞图"] forState:UIControlStateNormal];
        if ([[mainCom valueForKey:@"comment_id"] intValue] == -1 ) {
            [((UIButton*)[cell viewWithTag:5]) setHidden:YES];
            [cell.zanView setHidden:YES];
            [cell.waitView startAnimating];
            [cell.resend_Button setHidden:YES];
            
            
        }else if([[mainCom valueForKey:@"comment_id"] intValue] == -2){
            [((UIButton*)[cell viewWithTag:5]) setHidden:YES];
            [cell.zanView setHidden:YES];
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:NO];
            [cell.resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];

        }else{
            [cell.waitView stopAnimating];
            [cell.zanView setHidden:NO];
            [cell.resend_Button setHidden:YES];
            if (![[mainCom valueForKey:@"author"] isEqualToString:[MTUser sharedInstance].name]) {
                [((UIButton*)[cell viewWithTag:5]) setHidden:YES];
            }
            else{
                [((UIButton*)[cell viewWithTag:5]) setHidden:NO];
            }
        }
        [self.commentIds setObject:[mainCom valueForKey:@"comment_id"] atIndexedSubscript:indexPath.section-1];
        
        PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:(UIImageView*)[cell viewWithTag:1] authorId:[mainCom valueForKey:@"author_id"]];
        [avatarGetter getAvatar];
        
        return cell;
    }
    else
    {
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
            [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:242/255.0]];
            UIView *content = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 30)];
            [content setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
            [cell addSubview:content];
            UILabel* more = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 100, 30)];
            [more setBackgroundColor:[UIColor clearColor]];
            [more setText:@"查看更多评论"];
            [more setTextAlignment:NSTextAlignmentCenter];
            [more setFont:[UIFont systemFontOfSize:12]];
            [content addSubview:more];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        }

        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([SCommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:sCellIdentifier];
            nibsRegistered = YES;
        }
        SCommentTableViewCell *cell = (SCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
        NSDictionary *subCom = self.comment_list[indexPath.section - 1][[self.comment_list[indexPath.section - 1] count] - indexPath.row];
        
        NSString* text = [NSString stringWithFormat:@"%@ :%@",[subCom valueForKey:@"author"],[subCom valueForKey:@"content"]];
        cell.originComment = [subCom valueForKey:@"content"];
        NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
        [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,((NSString*)[subCom valueForKey:@"author"]).length)];
        cell.comment.authorLength = ((NSString*)[subCom valueForKey:@"author"]).length;
        cell.comment.font = [UIFont systemFontOfSize:SubCFontSize];
        [cell.comment setNumberOfLines:0];
        [cell.comment setLineBreakMode:NSLineBreakByCharWrapping];
        
        cell.comment.emojiText = text;
        //[((MLEmojiLabel*)cell.comment) setText:hintString1];

        if ([[subCom valueForKey:@"comment_id"] intValue] == -1 ) {
            [cell.waitView startAnimating];
            [cell.resend_Button setHidden:YES];
        }else if([[subCom valueForKey:@"comment_id"] intValue] == -2){
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:NO];
            [cell.resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [cell.waitView stopAnimating];
            [cell.resend_Button setHidden:YES];
        }

        float commentHeight = [self calculateTextHeight:text width:265 fontSize:SubCFontSize];
        CGRect frame = cell.frame;
        frame.size.height = commentHeight+0.5f;
        [cell setFrame:frame];
        frame = [cell viewWithTag:100].frame;
        frame.size.height =  commentHeight;
        [[cell viewWithTag:100] setFrame:frame];
        [cell.comment setFrame:CGRectMake(10, 0, 265, commentHeight)];
        cell.commentid = [subCom valueForKey:@"comment_id"];
        cell.authorid = [subCom valueForKey:@"author_id"];
        cell.author = [subCom valueForKey:@"author"];
        cell.controller = self;

        return cell;
    }
    
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString* text = [_event valueForKey:@"remark"];
        float commentHeight = [self calculateTextHeight:text width:300.0 fontSize:MainFontSize];
        if (commentHeight < 25) commentHeight = 25;
        return 248.0 + commentHeight;
    }
    else if (indexPath.row == 0) {
        NSDictionary *mainCom = self.comment_list[indexPath.section - 1][0];
        NSString* text = [mainCom valueForKey:@"content"];
        float commentHeight = [self calculateTextHeight:text width:280.0 fontSize:MainCFontSize];
        if (commentHeight < 25.0f) commentHeight = 25.0f;
        return 65.0f + commentHeight;
        
    }else
    {
        NSMutableArray *comments = self.comment_list[indexPath.section -1];
        if (indexPath.row > comments.count - 1) {
            return 30;
        }
        NSDictionary *subCom = self.comment_list[indexPath.section - 1][ [self.comment_list[indexPath.section - 1] count] - indexPath.row];
        NSString* text = [NSString stringWithFormat:@"%@ :%@",[subCom valueForKey:@"author"],[subCom valueForKey:@"content"]];
        
        float commentHeight = [self calculateTextHeight:text width:265.0 fontSize:SubCFontSize];
        return commentHeight+0.5;
    }
}


#pragma mark - TextField view delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    return YES;
}
#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
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
    //self.inputField.text = @"";
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
    [self.inputTextView resignFirstResponder];
}


#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if ([response1 valueForKey:@"comment_list"]) {
                int type = [[response1 valueForKey:@"type"]intValue];
                NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"comment_list"]];
                for (int i = 0; i < tmp.count; i++) {
                    tmp[i] = [[NSMutableArray alloc] initWithArray:tmp[i]];
                    for (int j = 0; j < ((NSMutableArray*)tmp[i]).count; j++) {
                        tmp[i][j] = [[NSMutableDictionary alloc]initWithDictionary:tmp[i][j]];
                    }
                }
                if (type == 0) {
                    
                    self.master_sequence = [response1 valueForKey:@"sequence"];
                    if (_Headeropen) [_comment_list removeAllObjects];
                    [self.comment_list addObjectsFromArray:tmp];
                    if (_Footeropen && [_master_sequence intValue] == -1) {
                        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
                        [NSTimer scheduledTimerWithTimeInterval:1.2f target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
                    }else if (_Footeropen || _Headeropen) {
                        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
                    }else [_tableView reloadData];
                }
            }
            
        }
            break;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([sender isKindOfClass:[EventDetailViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[PictureWallViewController class]]) {
            PictureWallViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = self.eventId;
            nextViewController.eventName = [self.event valueForKey:@"subject"];
        }
        if ([segue.destinationViewController isKindOfClass:[showParticipatorsViewController class]]) {
            showParticipatorsViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.canManage = _visibility;
            nextViewController.isMine = _isMine;
            nextViewController.visibility = _visibility;
            
        }
        if ([segue.destinationViewController isKindOfClass:[Event2DcodeViewController class]]) {
            Event2DcodeViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.eventInfo = _event;
        }
        if ([segue.destinationViewController isKindOfClass:[ReportViewController class]]) {
            ReportViewController *nextViewController = segue.destinationViewController;
            nextViewController.eventId = _eventId;
            nextViewController.event = [self.event valueForKey:@"subject"];
            nextViewController.type = 1;
        }
    }
}

-(void)textChangedExt:(NSNotification *)notification
{
    CGRect frame = _inputTextView.frame;
    float change = _inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && _inputTextView.contentSize.height < 120) {
        frame.size.height = _inputTextView.contentSize.height;
        [_inputTextView setFrame:frame];
        frame = _commentView.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [_commentView setFrame:frame];
    }
}


@end
