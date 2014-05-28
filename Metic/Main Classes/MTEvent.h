//
//  MTEvent.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTEvent : NSObject
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *remark;
@property(nonatomic,strong)NSNumber *member_count;
@property(nonatomic,strong)NSNumber *event_id;
@property(nonatomic,strong)NSString *launch_time;
@property(nonatomic,strong)NSString *updatetime;
@property(nonatomic,strong)NSNumber *longitude;
@property(nonatomic,strong)NSArray *memberids;
@property(nonatomic,strong)NSString *launcher;
@property(nonatomic,strong)NSNumber *launcher_id;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSString *time;
@property(nonatomic,strong)NSNumber *latitude;
@property(nonatomic,strong)NSString *endTime;
@property(nonatomic,strong)NSString *subject;
@end
