//
//  DynamicViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-25.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "DynamicViewController.h"
#import "EventDetailViewController.h"
#import "../Source/MLEmoji/TTTAttributedLabel/TTTAttributedLabel.h"
#import "../Utils/PhotoGetter.h"
#import "MobClick.h"

@interface DynamicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UIView *bar;
@property(nonatomic,strong) NSNumber* selete_Eventid;

@end

@implementation DynamicViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self createScrollingBar];
    _scrollView.delegate = self;
    _dynamic_tableView.delegate = self;
    _dynamic_tableView.dataSource = self;
    _atMe_tableView.delegate = self;
    _atMe_tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((AppDelegate*)[UIApplication sharedApplication].delegate).notificationDelegate = self;
    [_dynamic_tableView reloadData];
    [_atMe_tableView reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"新动态"];
    if (_updateEvents.count == 0 && _atMeEvents.count != 0) {
        [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"新动态"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_atMeEvents removeAllObjects];
    [_updateEvents removeAllObjects];
    [_updateEventIds removeAllObjects];
}
//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createScrollingBar
{
    _bar = [[UIView alloc]initWithFrame:CGRectMake(0, 32, 160, 3)];
    [_bar setBackgroundColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0f]];
    [self.view addSubview:_bar];
}



- (IBAction)dynamics_pressdown:(id)sender {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)atMe_pressdown:(id)sender {
    [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
}
#pragma mark tableView DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _dynamic_tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateCell"];
        if (_updateEvents) {
            NSDictionary *updateInfo = _updateEvents[indexPath.row];
            NSString* text = [NSString stringWithFormat:@"%@ 活动更新了",[updateInfo valueForKey:@"subject"]];
            NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
            [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,((NSString*)[updateInfo valueForKey:@"subject"]).length)];
            
            TTTAttributedLabel *update_label = (TTTAttributedLabel*)[cell viewWithTag:131];
            if (!update_label) {
                update_label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
                [cell addSubview:update_label];
                [update_label setTag:131];
            }
            
            [update_label setNumberOfLines:0];
            [update_label setLineBreakMode:NSLineBreakByTruncatingTail];
            [update_label setText:hintString1];
            
            }
        return cell;

    }else{
        UITableViewCell* cell;
        NSDictionary *atMeInfo = _atMeEvents[indexPath.row];
        int cmd = [[atMeInfo valueForKey:@"cmd"] intValue];
        if (cmd == 988) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"atMeCell"];
            UIImageView* avatar = (UIImageView*)[cell viewWithTag:11];
            PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:avatar authorId:[atMeInfo valueForKey:@"author_id"]];
            [avatarGetter getAvatar];
            
            ((UILabel*)[cell viewWithTag:2]).text = [atMeInfo valueForKey:@"author"];
            ((UILabel*)[cell viewWithTag:3]).text = [atMeInfo valueForKey:@"content"];
            ((UILabel*)[cell viewWithTag:4]).text = [atMeInfo valueForKey:@"time"];

        }else if(cmd == 989){
            cell = [tableView dequeueReusableCellWithIdentifier:@"atMeGoodCell"];
            UIImageView* avatar = (UIImageView*)[cell viewWithTag:21];
            PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:avatar authorId:[atMeInfo valueForKey:@"author_id"]];
            [avatarGetter getAvatar];
            ((UILabel*)[cell viewWithTag:2]).text = [atMeInfo valueForKey:@"author"];
        }
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _dynamic_tableView) {
        NSDictionary *updateInfo = _updateEvents[indexPath.row];
        _selete_Eventid = [updateInfo valueForKey:@"event_id"];
        [_updateEvents removeObjectAtIndex:indexPath.row];
        [_updateEventIds removeObject:_selete_Eventid];
        [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
    }else{
        NSDictionary *atMeInfo = _atMeEvents[indexPath.row];
        _selete_Eventid = [atMeInfo valueForKey:@"event_id"];
        [_atMeEvents removeObjectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
    }
    
    
    
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _dynamic_tableView) {
        if (_updateEvents && _updateEvents.count >0) {
            [_dynamic_empty_label setHidden:YES];
            return _updateEvents.count;
        }else{
            [_dynamic_empty_label setHidden:NO];
            return 0;
        }
    }
    else {
        if (_atMeEvents && _atMeEvents.count > 0) {
            [_atMe_empty_label setHidden:YES];
            return _atMeEvents.count;
        }else{
            [_atMe_empty_label setHidden:NO];
            return 0;
        }
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.destinationViewController isKindOfClass:[EventDetailViewController class]]) {
        EventDetailViewController *nextViewController = segue.destinationViewController;
        nextViewController.eventId = self.selete_Eventid;
    }

    
}

#pragma mark scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame =_bar.frame;
    frame.origin.x = scrollView.contentOffset.x / 2;
    [_bar setFrame:frame];
    if (scrollView.contentOffset.x > 88) {
        [_atMe_button setHighlighted:YES];
        [_dynamics_button setHighlighted:NO];
    }else{
        [_atMe_button setHighlighted:NO];
        [_dynamics_button setHighlighted:YES];
    }
}

#pragma mark notificationDidReceive
-(void)notificationDidReceive:(NSArray *)messages
{
    for (NSDictionary* message in messages) {
        NSLog(@"homeviewcontroller receive a message %@",message);
        NSString *eventInfo = [message valueForKey:@"content"];
        NSData *eventData = [eventInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:eventData options:NSJSONReadingMutableLeaves error:nil];
        int cmd = [[event valueForKey:@"cmd"] intValue];
        NSLog(@"cmd: %d",cmd);
        if (cmd == 993 || cmd == 992 || cmd == 991 || cmd == 988 || cmd == 989) {
            NSLog(@"%@",_updateEvents);
            if (_updateEvents.count == 0 && _atMeEvents.count != 0) {
                [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            }else if(_updateEvents.count != 0 && _atMeEvents.count == 0){
                [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            _dynamic_tableView.dataSource = self;
            _atMe_tableView.dataSource = self;
            [_dynamic_tableView reloadData];
            [_atMe_tableView reloadData];
        }
        
    }
}
@end
