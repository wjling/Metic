
//
//  EventDetailViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventDetailViewController.h"
#import "../CustomCellTableViewCell.h"
#import "CommentTableViewCell.h"
#import "MTUser.h"


@interface EventDetailViewController ()
@property(nonatomic,strong) NSDictionary *event;
//@property(nonatomic) int cellcount;

@end

@implementation EventDetailViewController

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
    
    self.scrollView.delegate = self;
    
    [self pullEventFromDB];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //[super viewDidAppear:animated];
    NSLog(@"%f",self.scrollView.contentSize.height);
    [self.scrollView setContentSize:CGSizeMake(320, 1000)];
    [super viewDidAppear:animated];
    NSLog(@"%f",self.scrollView.contentSize.height);
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%f",self.scrollView.contentSize.height);
    [self.scrollView setContentSize:CGSizeMake(320, 1000)];
    NSLog(@"%f",self.scrollView.contentSize.height);
}

#pragma mark - 数据库操作
- (void)updateEventToDB
{
    //    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    //    [self.sql openMyDB:path];
    //    for (NSDictionary *event in self.events) {
    //
    //        NSArray *columns = [[NSArray alloc]initWithObjects:@"'event_id'",@"'event_info'", nil];
    //        NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[event valueForKey:@"event_id"]],[NSString stringWithFormat:@"'%@'",[NSString jsonStringWithDictionary:event]], nil];
    //
    //        [self.sql insertToTable:@"event" withColumns:columns andValues:values];
    //    }
    //
    //    [self.sql closeMyDB];
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
    
    if (self.event) {
        
        _eventinfocell.eventName.text = [_event valueForKey:@"subject"];
        _eventinfocell.beginTime.text = [_event valueForKey:@"time"];
        _eventinfocell.endTime.text = [_event valueForKey:@"endTime"];
        _eventinfocell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[_event valueForKey:@"location"] ];
        
        _eventinfocell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %@ 人参加",(NSNumber*)[_event valueForKey:@"member_count"]];
        _eventinfocell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[_event valueForKey:@"launcher"] ];
        _eventinfocell.eventDetail.text = [[NSString alloc]initWithFormat:@"%@",[_event valueForKey:@"remark"] ];
        _eventinfocell.eventId = [_event valueForKey:@"event_id"];
    }
    
    
}
//
//
//#pragma mark 代理方法-UITableView
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 10   ;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.cellcount == 0) {
//        CustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customcell"];
//        if (cell == nil) {
//
//            cell = [[CustomCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
//                                                 reuseIdentifier:@"customcell"] ;
//        }
//        if (self.event) {
//            NSDictionary *a = self.event;
//            cell.eventName.text = [a valueForKey:@"subject"];
//            cell.beginTime.text = [a valueForKey:@"time"];
//            cell.endTime.text = [a valueForKey:@"endTime"];
//            cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
//
//            cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %@ 人参加",(NSNumber*)[a valueForKey:@"member_count"]];
//            cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
//            cell.eventDetail.text = [[NSString alloc]initWithFormat:@"%@",[a valueForKey:@"remark"] ];
//            cell.eventId = [a valueForKey:@"event_id"];
//        }
//        self.cellcount ++;
//        return cell;
//    }else{
//        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentcell"];
//        if (cell == nil) {
//
//            cell = [[CommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
//                                                 reuseIdentifier:@"commentcell"] ;
//        }
//        cell.publisher.text = @"aaa";
//        cell.comment.text = @"bbb";
//        self.cellcount ++;
//        return cell;
//
//
//    }
//	
//}



@end
