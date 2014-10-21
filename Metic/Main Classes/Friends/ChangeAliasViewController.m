//
//  ChangeAliasViewController.m
//  WeShare
//
//  Created by ligang_mac4 on 14-10-20.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "ChangeAliasViewController.h"

@interface ChangeAliasViewController ()

@end

@implementation ChangeAliasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [view1 setBackgroundColor:[UIColor yellowColor]];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [view2 setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:view1];
    [self.view addSubview:view2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initViews
{
    
}

@end
