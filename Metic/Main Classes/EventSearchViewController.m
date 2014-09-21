 //
//  EventSearchViewController.m
//  WeShare
//
//  Created by ligang6 on 14-9-21.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventSearchViewController.h"

@interface EventSearchViewController ()
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UISearchBar* searchBar;
@end

@implementation EventSearchViewController

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
    [_tableView setFrame:self.view.bounds];
    [_searchBar becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    
}

-(void)initUI
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0f]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [_searchBar setPlaceholder:@"搜索"];
    [self.view addSubview:_tableView];
    [self.tableView addSubview:_searchBar];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
