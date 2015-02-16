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
#import "PhotoDetailViewController.h"
#import "VideoDetailViewController.h"

@interface DynamicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UIView *bar;
@property(nonatomic,strong) NSNumber* selete_Eventid;

@end

@implementation DynamicViewController

enum pos{
    ALL = 0,
    LEFT = 1,
    RIGHT = 2,
};

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
    
    if (_updateEventStatus.count == 0 && _atMeEvents.count != 0) {
        [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }else if(_atMeEvents.count != 0){
        [self refreshRPoin:RIGHT];
    }
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
    if (_updateEventStatus.count == 0 && _atMeEvents.count != 0) {
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
    [_updateEventStatus removeAllObjects];
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

- (void)refreshRPoin:(NSInteger)pos
{
    switch (pos) {
        case LEFT:
            if (_scrollView.contentOffset.x != 0) {
                _dynamicRPoin.hidden = NO;
            }
            break;
        case RIGHT:
            if (_scrollView.contentOffset.x != 320) {
                _atMeRPoin.hidden = NO;
            }
            break;
        case ALL:
            if (_scrollView.contentOffset.x != 0) {
                _dynamicRPoin.hidden = NO;
            }
            if (_scrollView.contentOffset.x != 320) {
                _atMeRPoin.hidden = NO;
            }
            break;
    }
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
        if (_updateEventStatus) {
            
            NSArray *updateInfo = [_updateEventStatus objectForKey:[[_updateEventStatus keyEnumerator] allObjects][indexPath.row]];
            NSString* subject = updateInfo[0];
            
            float restWidth = 310;
            if ([updateInfo[1] boolValue]) {
                restWidth -= 34;
                UIImageView* image = (UIImageView*)[cell viewWithTag:991];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_video"]];
                    [image setTag:991];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:991];
                [image removeFromSuperview];
            }
            
            if ([updateInfo[2] boolValue]) {
                restWidth -= 34;
                UIImageView* image = (UIImageView*)[cell viewWithTag:992];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_photo"]];
                    [image setTag:992];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:992];
                [image removeFromSuperview];
            }
            
            if ([updateInfo[3] boolValue]) {
                restWidth -= 34;
                UIImageView* image = (UIImageView*)[cell viewWithTag:993];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_comment"]];
                    [image setTag:993];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:993];
                [image removeFromSuperview];
            }
            
            if (restWidth!= 310) {
                restWidth-=10;
            }
            
            
            
            NSString* text = [NSString stringWithFormat:@"%@ 活动更新了",subject];
            NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
            [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,subject.length)];
            
            TTTAttributedLabel *update_label = (TTTAttributedLabel*)[cell viewWithTag:131];
            if (!update_label) {
                update_label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(10, 0, restWidth, 50)];
                [cell addSubview:update_label];
                [update_label setTag:131];
            }else [update_label setFrame:CGRectMake(10, 0, restWidth, 50)];
            [update_label setNumberOfLines:0];
            [update_label setLineBreakMode:NSLineBreakByTruncatingTail];
            [update_label setText:hintString1];
            
            }
        return cell;

    }else{
        UITableViewCell* cell;
        NSDictionary *atMeInfo = _atMeEvents[_atMeEvents.count - 1 - indexPath.row];
        int cmd = [[atMeInfo valueForKey:@"cmd"] intValue];
        if (cmd == 986 || cmd == 987 || cmd == 988) {
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
        _selete_Eventid = [[_updateEventStatus keyEnumerator] allObjects][indexPath.row];
        [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
    }else{
        NSDictionary *atMeInfo = _atMeEvents[_atMeEvents.count - 1 - indexPath.row];
        int cmd = [[atMeInfo valueForKey:@"cmd"] intValue];
        _selete_Eventid = [atMeInfo valueForKey:@"event_id"];
        switch (cmd) {
            case 986:{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                         bundle: nil];
                VideoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"VideoDetailViewController"];
                
                viewcontroller.videoId = [atMeInfo valueForKey:@"video_id"];
                viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                viewcontroller.controller = nil;
                [self.navigationController pushViewController:viewcontroller animated:YES];
            }
                break;
            case 987:{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                         bundle: nil];
                PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
                
                viewcontroller.photoId = [atMeInfo valueForKey:@"photo_id"];
                viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                viewcontroller.controller = nil;
                viewcontroller.type = 2;
                [self.navigationController pushViewController:viewcontroller animated:YES];
            }
                
                break;
            case 988:
                if (_selete_Eventid) [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
                break;
            case 989:{
                int operation = [[atMeInfo valueForKey:@"operation"] intValue];
                switch (operation) {
                    case 1:
                    {
                        if (_selete_Eventid) [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
                    }
                        break;
                        
                    case 3:
                    {
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                                 bundle: nil];
                        PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
                        
                        viewcontroller.photoId = [atMeInfo valueForKey:@"photo_id"];
                        viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                        viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                        viewcontroller.controller = nil;
                        viewcontroller.type = 2;
                        [self.navigationController pushViewController:viewcontroller animated:YES];
                    }
                        break;
                        
                    case 5:
                    {
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                                 bundle: nil];
                        VideoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"VideoDetailViewController"];
                        
                        viewcontroller.videoId = [atMeInfo valueForKey:@"video_id"];
                        viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                        viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                        viewcontroller.controller = nil;
                        [self.navigationController pushViewController:viewcontroller animated:YES];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                if (_selete_Eventid) [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
                break;
        }
        
    }
    
    
    
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _dynamic_tableView) {
        if (_updateEventStatus && _updateEventStatus.count >0) {
            [_dynamic_empty_label setHidden:YES];
            return _updateEventStatus.count;
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
    if (scrollView == _scrollView) {
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
        
        if (scrollView.contentOffset.x == 0) {
            _dynamicRPoin.hidden = YES;
        }else if (scrollView.contentOffset.x == 320){
            _atMeRPoin.hidden = YES;
        }
        
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
        if (cmd == 993 || cmd == 992 || cmd == 991 || cmd == 986 || cmd == 987 || cmd == 988 || cmd == 989) {
            if (cmd == 993 || cmd == 992 || cmd == 991) {
                [self refreshRPoin:LEFT];
            }else [self refreshRPoin:RIGHT];
            [_dynamic_tableView reloadData];
            [_atMe_tableView reloadData];
        }
        
    }
}
@end
