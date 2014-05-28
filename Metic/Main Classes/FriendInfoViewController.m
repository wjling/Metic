//
//  FriendInfoViewController.m
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "FriendInfoViewController.h"

@interface FriendInfoViewController ()

@end

@implementation FriendInfoViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)testingClicked:(id)sender
{
    NSString* sql_CreateTable = @"CREATE TABLE IF NOT EXISTS USERINFO (user_id INTEGER PRIMARY KEY, user_name TEXT, gender INTEGER)";
    MySqlite* mine = [[MySqlite alloc]init];
    NSLog(@"db testing");
    [mine openMyDB:@"Metis.sqlite"];
//    [mine execSql:sql_CreateTable];
    
    [mine createTableWithTableName:@"USERINFO" andIndexWithProperties:@"user_id INTEGER PRIMARY KEY",@"user_name TEXT",@"gender INTEGER",nil];
    
    NSArray* columns = [[NSArray alloc]initWithObjects:@"user_id", @"user_name", @"gender", nil];
    NSArray* values = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:3],@"sb",[NSNumber numberWithInt:0], nil];
    [mine insertToTable:@"USERINFO" withColumns:columns andItsValues:values];
}

@end
