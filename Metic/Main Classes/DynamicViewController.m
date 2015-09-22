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
#import "UIImageView+MTWebCache.h"
#import "AtMeGoodTableViewCell.h"
#import "AtMeTableViewCell.h"

@interface DynamicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UIView *bar;
@property(nonatomic,strong) NSNumber* selete_Eventid;
@property(nonatomic,strong) NSNumber* selete_EventLauncherId;

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
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_VIDEO_NOTIFICATION];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_video"]];
                    [image setTag:NEW_VIDEO_NOTIFICATION];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_VIDEO_NOTIFICATION];
                [image removeFromSuperview];
            }
            
            if ([updateInfo[2] boolValue]) {
                restWidth -= 34;
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_PHOTO_NOTIFICATION];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_photo"]];
                    [image setTag:NEW_PHOTO_NOTIFICATION];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_PHOTO_NOTIFICATION];
                [image removeFromSuperview];
            }
            
            if ([updateInfo[3] boolValue]) {
                restWidth -= 34;
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_COMMENT_NOTIFICATION];
                if (!image) {
                    image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newmsg_comment"]];
                    [image setTag:NEW_COMMENT_NOTIFICATION];
                }
                [image setFrame:CGRectMake(restWidth+10, 13, 24, 24)];
                [cell addSubview:image];
            }else{
                UIImageView* image = (UIImageView*)[cell viewWithTag:NEW_COMMENT_NOTIFICATION];
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
        NSDictionary *atMeInfo = _atMeEvents[_atMeEvents.count - 1 - indexPath.row];
        int cmd = [[atMeInfo valueForKey:@"cmd"] intValue];
        if (cmd == NEW_VIDEO_COMMENT_REPLY || cmd == NEW_PHOTO_COMMENT_REPLY || cmd == NEW_COMMENT_REPLY) {
            AtMeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"atMeCell"];
            UIImageView* avatar = cell.avatar;
            avatar.layer.masksToBounds = YES;
            avatar.layer.cornerRadius = 4;
            PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:avatar authorId:[atMeInfo valueForKey:@"author_id"]];
            [avatarGetter getAvatar];
            cell.author.text = [atMeInfo valueForKey:@"author"];
            cell.content.text = [atMeInfo valueForKey:@"content"];
            cell.time.text = [atMeInfo valueForKey:@"time"];
            UIImageView* img = cell.contentImage;
            UILabel* lab = cell.contentLabel;
            NSString* object_content = [atMeInfo valueForKey:@"object_content"];
            if (cmd == NEW_VIDEO_COMMENT_REPLY || cmd == NEW_PHOTO_COMMENT_REPLY) {
                lab.text = @"";
                lab.hidden = YES;
                img.hidden = NO;
                if (object_content && img) {
                    img.layer.masksToBounds = YES;
                    img.layer.cornerRadius = 4;
                    img.contentMode = UIViewContentModeScaleAspectFit;
                    [img sd_setImageWithURL:[NSURL URLWithString:object_content] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] cloudPath:@"" completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            img.contentMode = UIViewContentModeScaleAspectFill;
                        }else{
                            img.image = [UIImage imageNamed:@"加载失败"];
                        }
                    }];
                }else img.image = nil;
            }else if (cmd == NEW_COMMENT_REPLY){
                img.image = nil;
                img.hidden = YES;
                lab.text = @"";
                lab.hidden = NO;
                if (object_content && lab) {
                    lab.layer.masksToBounds = YES;
                    lab.layer.cornerRadius = 4;
                    lab.text = object_content;
                }
            }
            return cell;
        }else if(cmd == NEW_LIKE_NOTIFICATION){
            AtMeGoodTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"atMeGoodCell"];
            UIImageView* avatar = cell.avatar;
            avatar.layer.masksToBounds = YES;
            avatar.layer.cornerRadius = 4;
            PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:avatar authorId:[atMeInfo valueForKey:@"author_id"]];
            [avatarGetter getAvatar];
            cell.author.text = [atMeInfo valueForKey:@"author"];
            UIImageView* img = cell.contentImage;
            UILabel* lab = cell.contentLabel;
            NSString* object_content = [atMeInfo valueForKey:@"object_content"];
            int operation = [[atMeInfo valueForKey:@"operation"] intValue];
            if (operation == 3 || operation == 5) {
                lab.text = @"";
                lab.hidden = YES;
                img.hidden = NO;
                if (object_content && img) {
                    img.layer.masksToBounds = YES;
                    img.layer.cornerRadius = 4;
                    img.contentMode = UIViewContentModeScaleAspectFit;
                    [img sd_setImageWithURL:[NSURL URLWithString:object_content] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]   cloudPath:@"" completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            img.contentMode = UIViewContentModeScaleAspectFill;
                        }else{
                            img.image = [UIImage imageNamed:@"加载失败"];
                        }
                    }];
                }else img.image = nil;
            }else if (operation == 1){
                img.image = nil;
                img.hidden = YES;
                lab.text = @"";
                lab.hidden = NO;
                if (object_content && lab) {
                    lab.layer.masksToBounds = YES;
                    lab.layer.cornerRadius = 4;
                    lab.text = object_content;
                }
            }
            return cell;
        }
    }
    return nil;
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
        _selete_EventLauncherId = [atMeInfo valueForKey:@"launcher_id"];
//        NSNumber* launcher_id = [atMeInfo valueForKey:@"launcher_id"];
        switch (cmd) {
            case NEW_VIDEO_COMMENT_REPLY:{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                         bundle: nil];
                VideoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"VideoDetailViewController"];
                
                viewcontroller.videoId = [atMeInfo valueForKey:@"video_id"];
                viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                viewcontroller.eventLauncherId = _selete_EventLauncherId;
                viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                viewcontroller.controller = nil;
                viewcontroller.canManage = YES;
                [self.navigationController pushViewController:viewcontroller animated:YES];
            }
                break;
            case NEW_PHOTO_COMMENT_REPLY:{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                         bundle: nil];
                PhotoDetailViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
                
                viewcontroller.photoId = [atMeInfo valueForKey:@"photo_id"];
                viewcontroller.eventId = [atMeInfo valueForKey:@"event_id"];
                viewcontroller.eventLauncherId = _selete_EventLauncherId;
                viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                viewcontroller.controller = nil;
                viewcontroller.type = 2;
                viewcontroller.canManage = YES;
                [self.navigationController pushViewController:viewcontroller animated:YES];
            }
                
                break;
            case NEW_COMMENT_REPLY:
                if (_selete_Eventid) [self performSegueWithIdentifier:@"DynamicToEventDetail" sender:self];
                break;
            case NEW_LIKE_NOTIFICATION:{
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
                        viewcontroller.eventLauncherId = [atMeInfo valueForKey:@"launcher_id"];
                        viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                        viewcontroller.controller = nil;
                        viewcontroller.type = 2;
                        viewcontroller.canManage = YES;
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
                        viewcontroller.eventLauncherId = [atMeInfo valueForKey:@"launcher_id"];
                        viewcontroller.eventName = [atMeInfo valueForKey:@"subject"];
                        viewcontroller.controller = nil;
                        viewcontroller.canManage = YES;
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
        //删除表项
        [_atMeEvents removeObject:atMeInfo];
        [_atMe_tableView reloadData];
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
        nextViewController.eventLauncherId = self.selete_EventLauncherId;
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
    for (int i = 0; i < messages.count; i++) {
        NSDictionary* message = [messages objectAtIndex:i];
        MTLOG(@"homeviewcontroller receive a message %@",message);
        NSString *eventInfo = [message valueForKey:@"content"];
        NSData *eventData = [eventInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *event =  [NSJSONSerialization JSONObjectWithData:eventData options:NSJSONReadingMutableLeaves error:nil];
        int cmd = [[event valueForKey:@"cmd"] intValue];
        MTLOG(@"cmd: %d",cmd);
        if (cmd == NEW_COMMENT_NOTIFICATION || cmd == NEW_PHOTO_NOTIFICATION || cmd == NEW_VIDEO_NOTIFICATION || cmd == NEW_VIDEO_COMMENT_REPLY || cmd == NEW_PHOTO_COMMENT_REPLY || cmd == NEW_COMMENT_REPLY || cmd == NEW_LIKE_NOTIFICATION) {
            if (cmd == NEW_COMMENT_NOTIFICATION || cmd == NEW_PHOTO_NOTIFICATION || cmd == NEW_VIDEO_NOTIFICATION) {
                [self refreshRPoin:LEFT];
            }else [self refreshRPoin:RIGHT];
            [_dynamic_tableView reloadData];
            [_atMe_tableView reloadData];
        }
        
    }
}
@end
