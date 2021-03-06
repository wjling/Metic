//
//  MTTableView.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTTableView.h"
//#import "../Cell/CustomCellTableViewCell.h"
#import "MTTableViewCellBase.h"

@implementation MTTableView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark 代理方法-UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.eventsSource && self.eventsSource.count != 0) {
        return self.eventsSource.count;
    }else
        return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTLOG(@"ddd");
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.eventsSource || self.eventsSource.count == 0) {
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,70)];
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
        
        label.text = _emptyTips;
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        label.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
        
        return cell;
    }
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:_cellClassName bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:_cellClassName];
        nibsRegistered = YES;
    }
    
    MTTableViewCellBase *cell = (MTTableViewCellBase *)[tableView dequeueReusableCellWithIdentifier:_cellClassName];
    cell.clipsToBounds = YES;
    cell.controller = self.homeController;

    if (self.eventsSource) {
        NSDictionary *data = self.eventsSource[indexPath.row];
        if (data) {
            [cell applyData:data];
        }
    }
    
	return cell;
}




@end
