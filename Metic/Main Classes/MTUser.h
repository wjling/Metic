//
//  MTUser.h
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTUser : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *email;
@property(nonatomic)bool logined;
@end
