//
//  MTUser.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpSender.h"
#import "AppConstants.h"

@interface MTUser : NSObject
@property(nonatomic,strong)NSNumber *userid;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSNumber *gender;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *sign;
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,strong)NSNumber *location;



@property(nonatomic)bool logined;
+ (MTUser *)sharedInstance;
- (void)getInfo:(NSNumber *) uid myid:(NSNumber *)myid delegateId:(id) aDelegate;
- (void)initWithData:(NSDictionary *)mdictionary;
- (void)setUserid:(NSNumber *)userid;

@end

