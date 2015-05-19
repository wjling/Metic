//
//  MTOperation.h
//  WeShare
//
//  Created by 俊健 on 15/5/20.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTOperation : NSObject
//添加那些把自己删掉的好友
+ (MTOperation *)sharedInstance;
-(void)inviteFriends:(NSArray*)notFriendsList;

@end
