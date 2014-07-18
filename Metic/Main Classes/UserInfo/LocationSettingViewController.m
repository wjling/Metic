//
//  LocationSettingViewController.m
//  Metic
//
//  Created by mac on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LocationSettingViewController.h"

@interface LocationSettingViewController ()
{
    NSArray* province_array;
    NSArray* selected_city_array;
    
    NSInteger selected_province_index;
    NSInteger selected_city_index;
}

@end

@implementation LocationSettingViewController
@synthesize LocationDic;
@synthesize navigationItem;
@synthesize left_barButton;
@synthesize right_barButton;
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
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Provinces" ofType:@"plist"];
    LocationDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    province_array = [LocationDic allKeys];
    
    [self.content_scrollView setScrollEnabled:NO];
    self.content_scrollView.showsHorizontalScrollIndicator = NO;
    self.content_scrollView.showsVerticalScrollIndicator = NO;
    
    navigationItem.title = @"请选择省份";
    [left_barButton setTarget:self];
    [right_barButton setTarget:self];
    [left_barButton setAction:@selector(leftBarButtonInProvinceClicked:)];
    [right_barButton setAction:@selector(rightBarButtonInProvinceClicked:)];
    
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

-(void)rightBarButtonInProvinceClicked:(id)sender
{
    CGPoint p = CGPointMake(320, 0);
    [self.content_scrollView setContentOffset:p animated:YES];
    navigationItem.title = @"请选择城市";
    [left_barButton setAction:@selector(leftBarButtonInCityClicked:)];
    [right_barButton setAction:@selector(rightBarButtonInCityClicked:)];
}

-(void)rightBarButtonInCityClicked:(id)sender
{
    NSString* province = [province_array objectAtIndex:selected_province_index];
    NSString* city = [selected_city_array objectAtIndex:selected_city_index];
    NSString* location = [NSString stringWithFormat:@"%@ %@",province,city];
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          location,@"location",nil  ];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
}

-(void)leftBarButtonInProvinceClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)leftBarButtonInCityClicked:(id)sender
{
    CGPoint p = CGPointMake(0, 0);
    [self.content_scrollView setContentOffset:p animated:YES];
    navigationItem.title = @"请选择省份";
    [left_barButton setAction:@selector(leftBarButtonInProvinceClicked:)];
    [right_barButton setAction:@selector(rightBarButtonInProvinceClicked:)];

}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.province_tableView) {
        return province_array.count;
    }
    else if(tableView == self.city_tableView)
    {
        return selected_city_array.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    if (tableView == self.province_tableView) {
        cell = [self.province_tableView dequeueReusableCellWithIdentifier:@"provincecell"];
        if (nil == cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"provincecell"];
        }
        cell.textLabel.text = [province_array objectAtIndex:indexPath.row];
        return cell;
    }
    else if(tableView == self.city_tableView)
    {
        cell = [self.city_tableView dequeueReusableCellWithIdentifier:@"citycell"];
        if (nil == cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"citycell"];
        }
        cell.textLabel.text = [selected_city_array objectAtIndex:indexPath.row];
        return cell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.province_tableView) {
        selected_province_index = indexPath.row;
        selected_city_array = [LocationDic objectForKey:[province_array objectAtIndex:selected_province_index]];
        [self.province_tableView reloadData];
    }
    else if(tableView == self.city_tableView)
    {
        selected_city_index = indexPath.row;
        [self.city_tableView reloadData];
    }

}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.city_tableView)
    {
        if (indexPath.row == selected_city_index) {
            return UITableViewCellAccessoryCheckmark;
        }
        
    }
    else if (tableView == self.province_tableView)
    {
        if (indexPath.row == selected_province_index) {
            return UITableViewCellAccessoryCheckmark;
        }
    }
    return UITableViewCellAccessoryNone;
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            
        }
            break;
            
        default:
            NSLog(@"性别修改失败");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"由于网络原因性别修改失败" WithDelegate:self WithCancelTitle:@"OK"];
            break;
    }
}


@end
