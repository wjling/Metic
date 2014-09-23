//
//  photoRankingViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-22.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "photoRankingViewController.h"
#import "PhotoRankingTableViewCell.h"
#import "MTUser.h"

@interface photoRankingViewController ()
@property(nonatomic,strong) NSMutableArray* photos;
@end

@implementation photoRankingViewController

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
    [self initData];
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width/32;
    frame.size.width = frame.size.width * 15/16;
    [self.tableView setFrame:frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    _shouldFlash = YES;
    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width/32;
    frame.size.width = frame.size.width * 15/16;
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    [self.view addSubview:_tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    [self getPhotoList];
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
}

-(void)getPhotoList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:50] forKey:@"number"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_GOOD_PHOTOS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"good_photos"]];
                    for (int i = 0; i < newphoto_list.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list[i]];
                        newphoto_list[i] = dictionary;
                    }
                    //[self updateVideoInfoToDB:newvideo_list];

                    _photos = newphoto_list;
                    
                    [self.tableView reloadData];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self closeRJ];
//                    });
//
                }
                    break;
                default:{
                }
            }
            
        }else{
        }
    }];
    
    
}

#pragma UITableView DataSource & Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_photos) return _photos.count;
    else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoRankingTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([PhotoRankingTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    PhotoRankingTableViewCell *cell = (PhotoRankingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (self.photos) {
        NSMutableDictionary *dictionary = self.photos[indexPath.row];
        cell.photoInfo = dictionary;
        cell.eventId = _eventId;
        cell.controller = self;
        [cell refresh];
        [cell animationBegin];
    }
    
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 226;
}
@end
