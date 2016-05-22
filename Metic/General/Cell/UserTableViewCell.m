//
//  UserInfoTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "UserTableViewCell.h"
#import "MTOperation.h"
#import "PhotoGetter.h"

@implementation UserTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applyData:(NSDictionary *)data {
    //显示备注名
    NSString *alias = [MTOperation getAliasWithUserId:data[@"id"] userName:data[@"name"]];
    
    self.name.text = alias;
    self.signature.text = ([[data valueForKey:@"sign"] isEqual:[NSNull null]])?@"":[data valueForKey:@"sign"];
    self.location.text = ([[data valueForKey:@"location"] isEqual:[NSNull null]])?@"":[data valueForKey:@"location"];
    self.genderImg.image = ([[data valueForKey:@"gender"] intValue] == 1)? [UIImage imageNamed:@"gender_male"]:[UIImage imageNamed:@"gender_female"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"id"]];
    [avatarGetter getAvatar];
}

@end
