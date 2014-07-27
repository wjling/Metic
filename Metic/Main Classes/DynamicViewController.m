//
//  DynamicViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-25.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "DynamicViewController.h"
#import "../Source/TTTAttributedLabel/TTTAttributedLabel.h"

@interface DynamicViewController ()
@property(nonatomic,strong) UIView *bar;

@end

@implementation DynamicViewController

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
    [self createScrollingBar];
    _scrollView.delegate = self;
    _dynamic_tableView.delegate = self;
    _dynamic_tableView.dataSource = self;
    _atMe_tableView.delegate = self;
    _atMe_tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createScrollingBar
{
    _bar = [[UIView alloc]initWithFrame:CGRectMake(0, 32, 160, 3)];
    [_bar setBackgroundColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0f]];
    [self.view addSubview:_bar];
}



- (IBAction)dynamics_pressdown:(id)sender {
}

- (IBAction)atMe_pressdown:(id)sender {
}

#pragma mark tableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _dynamic_tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateCell"];
        if (_updateEvents) {
            NSDictionary *updateInfo = _updateEvents[indexPath.row];
            NSString* text = [NSString stringWithFormat:@"%@ 活动更新了",[updateInfo valueForKey:@"subject"]];
            NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
            [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,((NSString*)[updateInfo valueForKey:@"subject"]).length)];
            
            TTTAttributedLabel *update_label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
            [update_label setNumberOfLines:0];
            [update_label setLineBreakMode:NSLineBreakByTruncatingTail];
            [update_label setText:hintString1];
            [cell addSubview:update_label];
            }
        return cell;

    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"atMeCell"];
        if (_updateEvents) {
            NSDictionary *updateInfo = _updateEvents[indexPath.row];
            NSString* text = [NSString stringWithFormat:@"%@ 活动更新了",[updateInfo valueForKey:@"subject"]];
            NSMutableAttributedString *hintString1 = [[NSMutableAttributedString alloc] initWithString:text];
            [hintString1 addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:46.0/255 green:171.0/255 blue:214.0/255 alpha:1.0f] CGColor] range:NSMakeRange(0,((NSString*)[updateInfo valueForKey:@"subject"]).length)];
            [hintString1 addAttribute:(NSString *)kCTFontSizeAttribute value:[UIFont systemFontOfSize:25] range:NSMakeRange(0,((NSString*)[updateInfo valueForKey:@"subject"]).length)];
            TTTAttributedLabel *update_label = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
            update_label.font = [UIFont systemFontOfSize:25.0];
            [update_label setLineBreakMode:NSLineBreakByTruncatingTail];
            [update_label setText:hintString1];
            [cell addSubview:update_label];
            
        }
        return cell;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView == _dynamic_tableView) {
//        
//    }
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _dynamic_tableView) {
        if (_updateEvents) {
            return _updateEvents.count;
        }else return 0;
    }
    else {
        if (_updateEvents) {
            return _updateEvents.count;
        }else return 0;
    }
}

#pragma mark scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
}
@end
