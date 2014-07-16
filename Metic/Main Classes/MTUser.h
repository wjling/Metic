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
#import "../Utils/HttpSender.h"
#import "MySqlite.h"
#import "CommonUtils.h"

@interface MTUser : NSObject<HttpSenderDelegate>
@property(nonatomic,strong)NSNumber *userid;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSNumber *gender;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *sign;
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSMutableDictionary *avatar;
@property(nonatomic,strong)NSMutableDictionary *avatarURL;
@property(nonatomic,strong)NSMutableDictionary *bannerURL;
@property(nonatomic,strong)NSMutableSet *friendIds;
//@property(nonatomic,strong)MySqlite *sql;
@property float wait;
@property(nonatomic,strong)NSMutableArray* friendList;
@property (strong,nonatomic)NSMutableDictionary* sortedFriendDic;
@property (strong,nonatomic) NSMutableArray* sectionArray;



@property(nonatomic)bool logined;
+ (MTUser *)sharedInstance;
- (void)getInfo:(NSNumber *) uid myid:(NSNumber *)myid delegateId:(id) aDelegate;
- (void) synchronizeFriends;
- (void) insertToFriendTable:(NSArray*)friends;
- (NSMutableArray*)getFriendsFromDB;
- (NSMutableDictionary*)sortFriendList;
- (void)rankFriendsInArray:(NSMutableArray*)friends;
//- (void)updateAvatar;
//- (void)updateAvatarList;
- (void)initWithData:(NSDictionary *)mdictionary;
- (void)setUid:(NSNumber *)user_id;

@end

