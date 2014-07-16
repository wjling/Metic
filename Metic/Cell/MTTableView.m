//
//  MTTableView.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTTableView.h"
#import "../Cell/CustomCellTableViewCell.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"





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
    if (self.eventsSource) {
        return self.eventsSource.count;
    }else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customcell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([CustomCellTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    CustomCellTableViewCell *cell = (CustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (self.eventsSource) {
        NSDictionary *a = self.eventsSource[indexPath.row];
        cell.eventName.text = [a valueForKey:@"subject"];
        NSString* beginT = [a valueForKey:@"time"];
        NSString* endT = [a valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        int participator_count = [[a valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
        cell.eventId = [a valueForKey:@"event_id"];
        cell.avatar.layer.masksToBounds = YES;
        [cell.avatar.layer setBorderColor:[UIColor yellowColor].CGColor];
        [cell.avatar.layer setBorderWidth:2.0f];
        [cell.avatar.layer setCornerRadius:15];

        
        if (![[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[NSString stringWithFormat:@"/avatar/%@.jpg",[a valueForKey:@"launcher_id"]]]) {
            cell.avatar.image = [UIImage imageNamed:@"默认用户头像"];
        }
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
        NSInvocationOperation *operation0 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(BGgetPhoto:) object:getter];
        [self.queue addOperation:operation0];
        //[getter getPhoto];
        
        
        
        
        if (![[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[NSString stringWithFormat:@"/banner/%@.jpg",[a valueForKey:@"event_id"]]]) {
            cell.themePhoto.image = [UIImage imageNamed:@"event.png"];
        }
        PhotoGetter *bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
        NSInvocationOperation *operation1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(BGgetBanner:) object:bannerGetter];
        [self.queue addOperation:operation1];
        //[bannerGetter getBanner];
        
        
        
        
        cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];

        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            if (i < participator_count) {
                if (![[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[NSString stringWithFormat:@"/avatar/%@.jpg",memberids[i]]]) {
                    cell.avatar.image = [UIImage imageNamed:@"默认用户头像"];
                }
                PhotoGetter *getter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                NSInvocationOperation *operation2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(BGgetPhoto:) object:getter];
                [self.queue addOperation:operation2];
                //[getter getPhoto];
            }else tmp.image = nil;
            
        }
    }
    
	return cell;
}

-(void)BGgetBanner:(id)sender
{
    PhotoGetter* getter = sender;
    [getter getBanner];
}
-(void)BGgetPhoto:(id)sender
{
    PhotoGetter* getter = sender;
    [getter getPhoto];
}

@end
