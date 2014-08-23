//
//  MTUser.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTUser.h"
#import "../Utils/PhotoGetter.h"
#import "SDImageCache.h"


@interface MTUser ()
{
    NSString* DB_path;
}
@property(nonatomic,strong) NSArray *avatarInfo;
@end

@implementation MTUser
@synthesize userid;
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize friendsIdSet;
@synthesize nameFromID_dic;

@synthesize updateEventIds;
@synthesize updateEvents;
@synthesize atMeEvents;

@synthesize msgFromDB;
@synthesize eventRequestMsg;
@synthesize friendRequestMsg;
@synthesize systemMsg;
@synthesize historicalMsg;
@synthesize hasInitNotification;

static MTUser *singletonInstance;

+ (MTUser *)sharedInstance
{
	return singletonInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        singletonInstance = self;
        self.avatar = [[NSMutableDictionary alloc]init];
        self.avatarURL = [[NSMutableDictionary alloc]init];
        self.bannerURL = [[NSMutableDictionary alloc]init];
        self.photoURL = [[NSMutableDictionary alloc]init];
        self.friendList = [[NSMutableArray alloc]initWithCapacity:0];
        self.sortedFriendDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.sectionArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.friendsIdSet = [[NSMutableSet alloc]init];
        self.updateEventIds = [[NSMutableSet alloc]init];
        self.updateEvents = [[NSMutableArray alloc]init];
        self.atMeEvents = [[NSMutableArray alloc]init];
        self.eventRequestMsg = [[NSMutableArray alloc]init];
        self.friendRequestMsg = [[NSMutableArray alloc]init];
        self.systemMsg = [[NSMutableArray alloc]init];
        self.historicalMsg = [[NSMutableArray alloc]init];
        self.hasInitNotification = NO;
       
        self.wait = 0.1;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        singletonInstance = self;
        _avatar = [aDecoder decodeObjectForKey:@"avatar"];
        _avatarURL = [aDecoder decodeObjectForKey:@"avatarURL"];
        _bannerURL = [aDecoder decodeObjectForKey:@"bannerURL"];
        _photoURL = [aDecoder decodeObjectForKey:@"photoURL"];
        friendList = [aDecoder decodeObjectForKey:@"friendList"];
        sortedFriendDic = [aDecoder decodeObjectForKey:@"sortedFriendDic"];
        sectionArray = [aDecoder decodeObjectForKey:@"sectionArray"];
        friendsIdSet = [aDecoder decodeObjectForKey:@"friendsIdSet"];
        updateEventIds = [aDecoder decodeObjectForKey:@"updateEventIds"];
        atMeEvents = [aDecoder decodeObjectForKey:@"atMeEvents"];
        eventRequestMsg = [aDecoder decodeObjectForKey:@"eventRequestMsg"];
        friendRequestMsg = [aDecoder decodeObjectForKey:@"friendRequestMsg"];
        systemMsg = [aDecoder decodeObjectForKey:@"systemMsg"];
        historicalMsg = [aDecoder decodeObjectForKey:@"historicalMsg"];
        userid = [aDecoder decodeObjectForKey:@"userid"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _gender = [aDecoder decodeObjectForKey:@"gender"];
        _email = [aDecoder decodeObjectForKey:@"email"];
        _sign = [aDecoder decodeObjectForKey:@"sign"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
        _location = [aDecoder decodeObjectForKey:@"location"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.avatarURL forKey:@"avatarURL"];
    [aCoder encodeObject:self.bannerURL forKey:@"bannerURL"];
    [aCoder encodeObject:self.photoURL forKey:@"photoURL"];
    [aCoder encodeObject:self.friendList forKey:@"friendList"];
    [aCoder encodeObject:self.sortedFriendDic forKey:@"sortedFriendDic"];
    [aCoder encodeObject:self.sectionArray forKey:@"sectionArray"];
    [aCoder encodeObject:self.friendsIdSet forKey:@"friendsIdSet"];
    [aCoder encodeObject:self.updateEventIds forKey:@"updateEventIds"];
    [aCoder encodeObject:self.atMeEvents forKey:@"atMeEvents"];
    [aCoder encodeObject:self.eventRequestMsg forKey:@"eventRequestMsg"];
    [aCoder encodeObject:self.friendRequestMsg forKey:@"friendRequestMsg"];
    [aCoder encodeObject:self.systemMsg forKey:@"systemMsg"];
    [aCoder encodeObject:self.historicalMsg forKey:@"historicalMsg"];
    [aCoder encodeObject:self.userid forKey:@"userid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.sign forKey:@"sign"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.location forKey:@"location"];
}



- (void)getInfo:(NSNumber *)uid myid:(NSNumber *)myid delegateId:(id) aDelegate
{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:myid forKey:@"myid"];
    [dictionary setValue:uid forKey:@"id"];
    NSLog(@"getInfo:\n%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:aDelegate];
    [httpSender sendMessage:jsonData withOperationCode:GET_USER_INFO];

}

-(void)updateAvatarList
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.userid  forKey:@"id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_AVATAR_UPDATETIME finshedBlock:^(NSData *rData) {
        if (rData) {
            NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {
                    self.avatarInfo = [response1 valueForKey:@"list"];
                    [self updateAvatar];
                }
                    break;
                default:
                {
                }
                    break;
            }
        }
    }];
    
}

-(void)updateAvatar
{
    MySqlite *sql = [[MySqlite alloc]init];
    NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
    [sql openMyDB:path];
    NSLog(@"%@",self.avatarInfo);
    for (NSDictionary *dictionary in self.avatarInfo) {
        NSArray *seletes = [[NSArray alloc]initWithObjects:@"updatetime", nil];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[dictionary valueForKey:@"id"],@"id", nil];
        NSMutableArray *results = [sql queryTable:@"avatar" withSelect:seletes andWhere:wheres];
        if (!results.count) {
            NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
            NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
            [sql insertToTable:@"avatar" withColumns:columns andValues:values];
        }else{
            NSDictionary* result = results[0];
            NSString *local_update = [result valueForKey:@"updatetime"];
            NSString *net_update = [dictionary valueForKey:@"updatetime"];
            if (![local_update isEqualToString:net_update]) {
                NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
                NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
                [sql insertToTable:@"avatar" withColumns:columns andValues:values];
                NSString* avatarUrl =[CommonUtils getUrl:[NSString stringWithFormat:@"/avatar/%@.jpg",[dictionary valueForKey:@"id"]]];
                [[SDImageCache sharedImageCache] removeImageForKey:avatarUrl withCompletition:^{
                    NSLog(@"删除 id号：%@ 用户的头像",[dictionary valueForKey:@"id"]);
                }];
            }
        }
    }
    [sql closeMyDB];
}

- (void)setUid:(NSNumber*) user_id
{
    userid = user_id;
    NSLog(@"set user id: %@", self.userid);
    DB_path = [NSString stringWithFormat:@"%@/db",self.userid];
    [self initUserDir];
    
//    [self.friendList removeAllObjects];
//    [self.sortedFriendDic removeAllObjects];
    [self.sectionArray removeAllObjects];
    [self synchronizeFriends];
    [NSThread detachNewThreadSelector:@selector(getMsgFromDataBase) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(systemSettingsInit:) toTarget:self withObject:user_id];
}

- (void)initUserDir
{
    NSString* mediaDir= [NSString stringWithFormat:@"%@/Documents/media", NSHomeDirectory()];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:mediaDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:mediaDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:[mediaDir stringByAppendingString:@"/avatar"]  withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:[mediaDir stringByAppendingString:@"/images"]  withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:[mediaDir stringByAppendingString:@"/banner"]  withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    NSString* userDir= [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), self.userid];
    isDir = NO;
    existed = [fileManager fileExistsAtPath:userDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:userDir withIntermediateDirectories:YES attributes:nil error:nil];
      
        NSLog(@"init user DB");
        [self performSelectorOnMainThread:@selector(initUserDB) withObject:nil waitUntilDone:YES];
    }
    
    
}

- (void)initUserDB
{
    MySqlite * sql = [[MySqlite alloc]init];
    NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
    [sql openMyDB:path];
    [sql createTableWithTableName:@"event" andIndexWithProperties:@"event_id INTEGER PRIMARY KEY UNIQUE",@"event_info",nil];
    [sql createTableWithTableName:@"notification" andIndexWithProperties:@"seq INTEGER PRIMARY KEY UNIQUE",@"timestamp",@"msg",@"ishandled",nil];
    [sql createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",nil];
    [sql createTableWithTableName:@"avatar" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"updatetime",nil];
    [sql createTableWithTableName:@"eventPhotos" andIndexWithProperties:@"photo_id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"photoInfo",nil];
    [sql closeMyDB];
    //self.logined = YES;
}

- (void)initWithData:(NSDictionary *)mdictionary
{
    self.userid = [mdictionary valueForKey:@"id"];
    self.name = [mdictionary valueForKey:@"name"];
    self.gender = [mdictionary valueForKey:@"gender"];
    self.sign = [mdictionary valueForKey:@"sign"];
    self.phone = [mdictionary valueForKey:@"phone"];
    self.location = [mdictionary valueForKey:@"location"];
    self.email = [mdictionary valueForKey:@"email"];
    
}

-(void)systemSettingsInit:(NSNumber*)uid
{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",uid]];
    if (!userSettings) {
        userSettings = [[NSMutableDictionary alloc]init];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting1"];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting2"];
        [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"hasUploadPhoneNumber"];
        [userDf setObject:userSettings forKey:[NSString stringWithFormat:@"USER%@",uid]];
        [userDf synchronize];
    }
}

//======================================SYNCHRONIZE FRIENDS=================================

- (void) synchronizeFriends
{
    self.friendList = [self getFriendsFromDB];
    self.nameFromID_dic = [[NSMutableDictionary alloc]init];
    for (NSDictionary* friend in friendList) {
        NSNumber* fid = [CommonUtils NSNumberWithNSString:[friend objectForKey:@"id"]];
        NSString* fname = [friend objectForKey:@"name"];
        [friendsIdSet addObject:fid];
        [nameFromID_dic setValue:fname forKey:[NSString stringWithFormat:@"%@",fid]];
    }
    NSLog(@"get friends from DB, friendList: %@",self.friendList);
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          self.userid,@"id",
                          [NSNumber numberWithInteger:self.friendList.count],@"friends_number",nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];
    NSLog(@"synchronize friend json: %@",json);
}

- (NSMutableArray*)getFriendsFromDB
{
    NSMutableArray* friends;
    MySqlite* db = [[MySqlite alloc]init];
    [db openMyDB:DB_path];
    friends = [db queryTable:@"friend" withSelect:[[NSArray alloc]initWithObjects:@"*", nil] andWhere:nil];
    [db closeMyDB];
    return friends;
}

- (NSMutableDictionary*)sortFriendList
{
    BOOL hasSpecialChar = NO;
    [self.sectionArray removeAllObjects];
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
    //    NSLog(@"friendlist count: %d",friendList.count);
    for (NSMutableDictionary* aFriend in self.friendList) {
        NSString* fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
        //        NSLog(@"friend name: %@",fname_py);
        NSString *regex = @"[a-zA-Z]";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        NSString* first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
        BOOL isSpecialChar = ! [predicate evaluateWithObject:first_letter];
        if (isSpecialChar) {
            first_letter = @"#";
            hasSpecialChar = YES;
        }
        NSMutableArray* groupOfFriends = [sorted objectForKey:[first_letter uppercaseString]];
        
        if (groupOfFriends) {
            [groupOfFriends addObject:aFriend];
            //            NSLog(@"a friend: %@",aFriend);
        }
        else
        {
            groupOfFriends = [[NSMutableArray alloc]init];
            [groupOfFriends addObject:aFriend];
            [sorted setObject:groupOfFriends forKey:[first_letter uppercaseString]];
            if (!isSpecialChar) {
                [self.sectionArray addObject:[first_letter uppercaseString]];
            }
            
        }
    }
    
    for (NSString* key in sorted) {
        NSMutableArray* arr = [sorted objectForKey:key];
        [self rankFriendsInArray:arr];
        //        NSLog(@"sorted array: %@",arr);
    }
    [self.sectionArray sortUsingComparator:^(id obj1, id obj2)
     {
         return [(NSString*)obj1 compare:(NSString*)obj2];
     }];
    
    NSDictionary* temp_dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"好友推荐",@"name", nil];
    NSArray* temp_arr = [[NSArray alloc]initWithObjects:temp_dic, nil];
    [sorted setObject:temp_arr forKey:@"★"];
    
    [sectionArray insertObject:@"★" atIndex:0];
    if (hasSpecialChar) {
        [sectionArray addObject:@"#"];
    }
    NSLog(@"sorted friends dictionary: %@",sorted);
    NSLog(@"section array: %@",self.sectionArray);
    return sorted;
}

- (void)rankFriendsInArray:(NSMutableArray*)friends
{
    NSComparator cmptor = ^(id obj1, id obj2)
    {
        NSString* obj1_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj1 objectForKey:@"name"]] uppercaseString];
        NSString* obj2_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj2 objectForKey:@"name"]] uppercaseString];
        NSInteger result = [obj1_py compare:obj2_py];
        return result;
    };
    [friends sortUsingComparator:cmptor];
}

- (void) insertToFriendTable:(NSArray *)friends
{
    //    NSString* path = [NSString stringWithFormat:@"%@/db",user.userid];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:DB_path];
    for (NSDictionary* friend in friends) {
        NSString* friendEmail = [friend objectForKey:@"email"];
        NSNumber* friendID = [friend objectForKey:@"id"];
        NSNumber* friendGender = [friend objectForKey:@"gender"];
        NSString* friendName = [friend objectForKey:@"name"];
        
        //        NSLog(@"email: %@, id: %@, gender: %@, name: %@",friendEmail,friendID,friendGender,friendName);
        
        NSArray* columns = [[NSArray alloc]initWithObjects:@"'id'",@"'name'",@"'email'",@"'gender'", nil];
        NSArray* values = [[NSArray alloc]initWithObjects:
                           [NSString stringWithFormat:@"%@",friendID],
                           [NSString stringWithFormat:@"'%@'",friendName],
                           [NSString stringWithFormat:@"'%@'",friendEmail],
                           [NSString stringWithFormat:@"%@",friendGender], nil];
        [sql insertToTable:@"friend" withColumns:columns andValues:values];
    }
    [sql closeMyDB];
    
    NSLog(@"好友列表更新完成！");
}

-(void)friendListDidChanged
{
    self.sortedFriendDic = [self sortFriendList];
    for (NSDictionary* friend in friendList) {
        NSNumber* fid = [CommonUtils NSNumberWithNSString:[friend objectForKey:@"id"]];
        NSString* fname = [friend valueForKey:@"name"];
        [friendsIdSet addObject:fid];
        [nameFromID_dic setValue:fname forKey:[NSString stringWithFormat:@"%@",fid]];
    }
    NSLog(@"friend id set: %@",friendsIdSet);
}



//============================================================================

//================================Init Notification Messages=====================

- (void) getMsgFromDataBase
{
    [self.eventRequestMsg removeAllObjects];
    [self.friendRequestMsg removeAllObjects];
    [self.systemMsg removeAllObjects];
    MySqlite* mySql = [[MySqlite alloc]init];
    [mySql openMyDB:DB_path];
    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq",@"ishandled", nil] andWhere:nil];
    [mySql closeMyDB];
    NSLog(@"msg from db: %@",msgFromDB);
    //    [self.notificationsTable reloadData];
    NSInteger count = self.msgFromDB.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        NSDictionary* msg = [msgFromDB objectAtIndex:i];
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        NSNumber* seq = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"seq"]];
        //        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
        //            NSLog(@"seq is string");
        //        }
        //        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
        //        {
        //            NSLog(@"seq is number");
        //        }
        NSNumber* ishandled = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"ishandled"]];
        
        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
        [msg_dic setValue:ishandled forKey:@"ishandled"];
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        if ([ishandled integerValue] == -1) {
            switch (cmd) {
                case ADD_FRIEND_NOTIFICATION:
                {
                    [self.friendRequestMsg addObject:msg_dic];
                }
                    break;
                case ADD_FRIEND_RESULT:
                case EVENT_INVITE_RESPONSE:
                {
                    [self.systemMsg addObject:msg_dic];
                }
                    break;
                case NEW_EVENT_NOTIFICATION:
                {
                    [self.eventRequestMsg addObject:msg_dic];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else
        {
            [self.historicalMsg addObject:msg_dic];
        }
    }
//    self.hasInitNotification = YES;
    [self performSelectorOnMainThread:@selector(getMsgFromDataBaseDone) withObject:nil waitUntilDone:YES];
    
}

-(void)getMsgFromDataBaseDone
{
    self.hasInitNotification = YES;
}


//===============================================================================

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            //self.avatarInfo = [response1 valueForKey:@"list"];
            //[self updateAvatar];NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            if (tempFriends) {
                if (tempFriends.count) {
                    self.friendList = tempFriends;
                    
                    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:tempFriends];
                    [thread start];
                }
                else
                {
                    NSLog(@"好友列表已经是最新的啦～");
//                    self.friendList = [self getFriendsFromDB];
//                    self.sortedFriendDic = [self sortFriendList];
                }
                NSLog(@"synchronize friends: %@",friendList);
                
            }
            [self friendListDidChanged];
                    
        }
            break;
        default:
        {
            
            //[CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
    }
}


@end
