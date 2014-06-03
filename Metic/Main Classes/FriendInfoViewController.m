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
//    NSString* sql_CreateTable = @"CREATE TABLE IF NOT EXISTS USERINFO (user_id INTEGER PRIMARY KEY, user_name TEXT, gender INTEGER)";
    MySqlite* mine = [[MySqlite alloc]init];
    NSLog(@"db testing");
    [mine openMyDB:@"Metis.sqlite"];
//    [mine execSql:sql_CreateTable];
    
    [mine createTableWithTableName:@"USERINFO" andIndexWithProperties:@"user_id INTEGER PRIMARY KEY UNIQUE",@"user_name TEXT",@"gender INTEGER",nil];
    
    NSArray* columns1 = [[NSArray alloc]initWithObjects:@"'user_id'", @"'user_name'", @"'gender'", nil];
    NSArray* values1 = [[NSArray alloc]initWithObjects:@"2",@"'sb1'",@"0",nil];
    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values1];
    
    NSArray* values2 = [[NSArray alloc]initWithObjects:@"5",@"'sbhhh'",@"0",nil];
    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values2];
    
    NSArray* values3 = [[NSArray alloc]initWithObjects:@"3",@"'xxxxf'",@"1",nil];
    [mine insertToTable:@"USERINFO" withColumns:columns1 andValues:values3];

    
//    NSArray* columns2 = [[NSArray alloc]initWithObjects:@"'user_name'", @"'gender'", nil];
//    NSArray* values4 = [[NSArray alloc]initWithObjects:@"'hi,sbb'",@"0",nil];
//    [mine updateDataWitTableName:@"USERINFO" andWhere:@"user_id" andItsValue:@"5" withColumns:columns2 andValues:values4];
    
//    NSArray* columns3 = [[NSArray alloc]initWithObjects:@"'user_id'", @"'user_name'", nil];
//    NSArray* values5 = [[NSArray alloc]initWithObjects:@"5",@"'hello,sbb'",nil];
//    [mine insertToTable:@"USERINFO" withColumns:columns3 andValues:values5];
    
    NSDictionary* wheres = [[NSDictionary alloc]initWithObjectsAndKeys:@"5",@"user_id", nil];
    NSDictionary* sets = [[NSDictionary alloc]initWithObjectsAndKeys:@"'yooooosb'",@"user_name",@"1",@"gender", nil];
    [mine updateDataWitTableName:@"'USERINFO'" andWhere:wheres andSet:sets];
    
    NSArray* columns4 = [[NSArray alloc]initWithObjects:@"user_id", @"user_name", nil];
    NSDictionary* wheres1 = [[NSDictionary alloc]initWithObjectsAndKeys:@"'%sb%'",@"user_name", nil];
    NSMutableArray* results;
    results = [mine queryTable:@"USERINFO" withSelect:columns4 andWhere:wheres1];
    int count = results.count;
    for (int i = 0; i<count; i++) {
        NSLog(@"%d: %@\n",i,[results objectAtIndex:i]);
    }
    
     NSDictionary* wheres2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"'sb1'",@"user_name", nil];
    [mine deleteTurpleFromTable:@"USERINFO" withWhere:wheres2];


    [mine closeMyDB];
}

@end
