//
//  LocationSettingViewController.m
//  Metic
//
//  Created by mac on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "LocationSettingViewController.h"
#import "SVProgressHUD.h"

@interface LocationSettingViewController ()
{
    NSMutableArray* province_array;
    NSArray* selected_city_array;
    
    NSInteger selected_province_index;
    NSInteger selected_city_index;
    
    NSString* newLocation;
}

@end

@implementation LocationSettingViewController
@synthesize location_arr;
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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    // Do any additional setup after loading the view.
    selected_province_index = -1;
    selected_city_index = -1;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Provinces" ofType:@"plist"];
    location_arr = [[NSArray alloc]initWithContentsOfFile:plistPath];
    NSInteger count = location_arr.count;
    province_array = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i<count; i++) {
        NSDictionary* province = [location_arr objectAtIndex:i];
        [province_array addObject:[province objectForKey:@"ProvinceName"]];
    }
    MTLOG(@"province array: %@",province_array);
    
    [self.content_scrollView setScrollEnabled:NO];
    self.content_scrollView.showsHorizontalScrollIndicator = NO;
    self.content_scrollView.showsVerticalScrollIndicator = NO;
    
    self.province_tableView.delegate = self;
    self.province_tableView.dataSource = self;
    self.city_tableView.delegate = self;
    self.city_tableView.dataSource = self;
    
    navigationItem.title = @"请选择省份";
    right_barButton.hidden = YES;
    [left_barButton addTarget:self action:@selector(leftBarButtonInProvinceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right_barButton addTarget:self action:@selector(rightBarButtonInProvinceClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
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
    selected_city_array = [[location_arr objectAtIndex:selected_province_index] objectForKey:@"cities"];
    MTLOG(@"selected_city_array: %@",selected_city_array);
    [self.city_tableView reloadData];
    CGPoint p = CGPointMake(kMainScreenWidth, 0);
    [self.content_scrollView setContentOffset:p animated:YES];
    navigationItem.title = @"请选择城市";
    [left_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [right_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [left_barButton addTarget:self action:@selector(leftBarButtonInCityClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right_barButton addTarget:self action:@selector(rightBarButtonInCityClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)rightBarButtonInCityClicked:(id)sender
{
    NSString* province = [province_array objectAtIndex:selected_province_index];
    NSString* city = [[selected_city_array objectAtIndex:selected_city_index] objectForKey:@"CityName"];
    newLocation = [NSString stringWithFormat:@"%@ %@",province,city];
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          newLocation,@"location",nil  ];
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
    [left_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [right_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [left_barButton addTarget:self action:@selector(leftBarButtonInProvinceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right_barButton addTarget:self action:@selector(rightBarButtonInProvinceClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    UITableViewCell* cell = nil;
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
        NSDictionary* city = [selected_city_array objectAtIndex:indexPath.row];
        cell.textLabel.text = [city objectForKey:@"CityName"];
        return cell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.province_tableView) {
        selected_province_index = indexPath.row;
        [self.province_tableView reloadData];
        
        selected_city_array = [[location_arr objectAtIndex:selected_province_index] objectForKey:@"cities"];
        MTLOG(@"selected_city_array: %@",selected_city_array);
        [self.city_tableView reloadData];
        CGPoint p = CGPointMake(kMainScreenWidth, 0);
        [self.content_scrollView setContentOffset:p animated:YES];
        navigationItem.title = @"请选择城市";
        [left_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [right_barButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [left_barButton addTarget:self action:@selector(leftBarButtonInCityClicked:) forControlEvents:UIControlEventTouchUpInside];
        [right_barButton addTarget:self action:@selector(rightBarButtonInCityClicked:) forControlEvents:UIControlEventTouchUpInside];

    }
    else if(tableView == self.city_tableView)
    {
        selected_city_index = indexPath.row;
        [self.city_tableView reloadData];
        NSString* province = [province_array objectAtIndex:selected_province_index];
        NSString* city = [[selected_city_array objectAtIndex:selected_city_index] objectForKey:@"CityName"];
        newLocation = [NSString stringWithFormat:@"%@ %@",province,city];
        NSDictionary* json = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid,@"id",
                              newLocation,@"location",nil  ];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
        [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
        [SVProgressHUD showWithStatus:@"正在处理中" maskType:SVProgressHUDMaskTypeGradient];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
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
    if (!rData) {
        MTLOG(@"服务器返回为空");
        return;
    }
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            MTLOG(@"所在地修改成功");
            [SVProgressHUD dismissWithSuccess:@"地址修改成功" afterDelay:1];
            [MTUser sharedInstance].location = newLocation;
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            MTLOG(@"所在地修改失败");
            [SVProgressHUD dismissWithSuccess:@"地址修改失败" afterDelay:2];
            break;
    }
    
}

-(void)dismissHUD:(id)sender
{
    [SVProgressHUD dismissWithError:@"服务器未响应" afterDelay:1];
}


@end
