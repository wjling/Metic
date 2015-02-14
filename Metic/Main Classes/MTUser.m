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
#import "XGPush.h"
#import "AppDelegate.h"


@interface MTUser ()
{
    NSString* DB_path;
    NSTimer* synchronizeFriendTimer;
}
@property(nonatomic,strong) NSArray *avatarInfo;
@end

@implementation MTUser
@synthesize userid;
@synthesize saltValue;
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize sectionArray;
@synthesize friendsIdSet;
@synthesize nameFromID_dic;
@synthesize alias_dic;

@synthesize updateEventStatus;
@synthesize updatePVStatus;
@synthesize atMeEvents;

@synthesize msgFromDB;
@synthesize eventRequestMsg;
@synthesize friendRequestMsg;
@synthesize systemMsg;
@synthesize historicalMsg;

@synthesize hasInitNotification;
@synthesize getSynchronizeFriendResponse;
@synthesize doingSortingFriends;
@synthesize sortingFriendsDone;
@synthesize doingSynchronizeFriend;
@synthesize synchronizeFriendDone;

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
        self.alias_dic = [[NSMutableDictionary alloc]init];
        self.friendsIdSet = [[NSMutableSet alloc]init];
        self.updateEventStatus = [[NSMutableDictionary alloc]init];
        self.atMeEvents = [[NSMutableArray alloc]init];
        self.eventRequestMsg = [[NSMutableArray alloc]init];
        self.friendRequestMsg = [[NSMutableArray alloc]init];
        self.systemMsg = [[NSMutableArray alloc]init];
        self.historicalMsg = [[NSMutableArray alloc]init];
        self.hasInitNotification = NO;
        self.getSynchronizeFriendResponse = NO;
        self.doingSortingFriends = NO;
       
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
        alias_dic = [aDecoder decodeObjectForKey:@"alias_dic"];
        friendsIdSet = [aDecoder decodeObjectForKey:@"friendsIdSet"];
        updateEventStatus = [aDecoder decodeObjectForKey:@"updateEventStatus"];
        updatePVStatus = [aDecoder decodeObjectForKey:@"updatePVStatus"];
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
        saltValue = [aDecoder decodeObjectForKey:@"saltValue"];
        
        if(!updateEventStatus) updateEventStatus = [[NSMutableDictionary alloc]init];
        if(!updatePVStatus) updatePVStatus = [[NSMutableDictionary alloc]init];
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
    [aCoder encodeObject:self.alias_dic forKey:@"alias_dic"];
    [aCoder encodeObject:self.friendsIdSet forKey:@"friendsIdSet"];
    [aCoder encodeObject:self.updateEventStatus forKey:@"updateEventStatus"];
    [aCoder encodeObject:self.updatePVStatus forKey:@"updatePVStatus"];
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
    [aCoder encodeObject:self.saltValue forKey:@"saltValue"];
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
                    NSLog(@"%@",_avatarInfo);
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
    
    NSString *account = [NSString stringWithFormat:@"%@_hdb",[MTUser sharedInstance].userid];
    NSLog(@"设置别名: %@",account);
    [XGPush setAccount:account];
    
    
     [(AppDelegate*)([UIApplication sharedApplication].delegate) registerPush];
    
    [self getAliasFromDB];
    [self getAliasFromServer];
    [NSThread detachNewThreadSelector:@selector(getMsgFromDataBase) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(systemSettingsInit:) toTarget:self withObject:user_id];
    
    //同步推送消息
    NSLog(@"开始同步消息");
    void(^synchronizeDone)(NSNumber*, NSNumber*) = ^(NSNumber* min_seq, NSNumber* max_seq)
    {
        if (!min_seq || !max_seq) {
            return;
        }
        [(AppDelegate*)([UIApplication sharedApplication].delegate) pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:nil];
    };
    [(AppDelegate*)([UIApplication sharedApplication].delegate) synchronizePushSeqAndCallBack:synchronizeDone];
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
    else
    {
        
        NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
        NSString* version = [userDfs objectForKey:@"DB_version"];
        int result;
        if (!version) {
            version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            [userDfs setValue:version forKey:@"DB_version"];
            [userDfs synchronize];
            result = -1;
        }
        else
        {
            result = [CommonUtils compareVersion1:version andVersion2:@"0.1.18"];
            
            version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            [userDfs setValue:version forKey:@"DB_version"];
            [userDfs synchronize];
        }
        
        
        if (result == -1) {
            NSLog(@"升级数据库，原数据库版本：%@",version);
            MySqlite * sql = [[MySqlite alloc]init];
            NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
            [sql openMyDB:path];
            [sql table:@"friend" addsColumn:@"alias" withDefault:nil];
            [sql closeMyDB];
        }
    }
    
    
}

- (void)initUserDB
{
    NSLog(@"初始化数据库");
    NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [userDfs setValue:version forKey:@"DB_version"];
    [userDfs synchronize];
    MySqlite * sql = [[MySqlite alloc]init];
    NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
    [sql openMyDB:path];
    [sql createTableWithTableName:@"event" andIndexWithProperties:@"event_id INTEGER PRIMARY KEY UNIQUE",@"event_info",nil];
    [sql createTableWithTableName:@"notification" andIndexWithProperties:@"seq INTEGER PRIMARY KEY UNIQUE",@"timestamp",@"msg",@"ishandled",nil];
    [sql createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",@"alias",nil];
    [sql createTableWithTableName:@"avatar" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"updatetime",nil];
    [sql createTableWithTableName:@"eventPhotos" andIndexWithProperties:@"photo_id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"photoInfo",nil];
    [sql createTableWithTableName:@"eventVideo" andIndexWithProperties:@"video_id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"videoInfo",nil];
    
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
        NSLog(@"重置用户设置信息");
        userSettings = [[NSMutableDictionary alloc]init];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting1"];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting2"];
        [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"hasUploadPhoneNumber"];
        [userSettings setValue:[NSMutableDictionary dictionary] forKey:@"hasUnreadNotification1"];
        [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"openWithNotificationCenter"];
        [userDf setObject:userSettings forKey:[NSString stringWithFormat:@"USER%@",uid]];
        [userDf synchronize];
    }
}

//======================================SYNCHRONIZE FRIENDS=================================

- (void) synchronizeFriends
{
    NSLog(@"synchronizeFriends begin");
    getSynchronizeFriendResponse = NO;
    doingSynchronizeFriend = YES;
    synchronizeFriendDone = NO;
    
    synchronizeFriendTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(synchronizeTimerDoing) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:synchronizeFriendTimer forMode:NSRunLoopCommonModes];
    
    self.friendList = [self getFriendsFromDB];
    self.nameFromID_dic = [[NSMutableDictionary alloc]init];
    for (NSDictionary* friend in friendList) {
        NSNumber* fid = [CommonUtils NSNumberWithNSString:[friend objectForKey:@"id"]];
        NSString* fname = [friend objectForKey:@"name"];
        [friend setValue:fid forKey:@"id"];
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
    NSLog(@"synchronizeFriends end");
}

-(void)synchronizeTimerDoing
{
    doingSynchronizeFriend = NO;
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
    doingSortingFriends = YES;
    sortingFriendsDone = NO;
    BOOL hasSpecialChar = NO;
    [self.sectionArray removeAllObjects];
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
    NSLog(@"before sort, friendlist: %@",friendList);
    for (NSMutableDictionary* aFriend in self.friendList) {
        NSString* fAlias = [aFriend objectForKey:@"alias"];
        NSString* fname_py;
        NSLog(@"alias: %@----%@",fAlias,[fAlias class]);
        if (fAlias) {
            if (![fAlias isEqual:[NSNull null]] && ![fAlias isEqualToString:@""]) {
                fname_py = [CommonUtils pinyinFromNSString:fAlias];
            }
            else
            {
                fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
            }
        }
        else
        {
            fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];

        }
        NSLog(@"friend name: %@",fname_py);
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
    
    for (NSString* key in sectionArray) {
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
    sortingFriendsDone = YES;
    doingSortingFriends = NO;
    return sorted;
}

- (void)rankFriendsInArray:(NSMutableArray*)friends
{
    NSComparator cmptor = ^(id obj1, id obj2)
    {
        NSString* alias1 = [obj1 objectForKey:@"alias"];
        NSString* alias2 = [obj2 objectForKey:@"alias"];
        NSString* obj1_py;
        NSString* obj2_py;
        if (alias1) {
            if (![alias1 isEqual:[NSNull null]]) {
                obj1_py = [[CommonUtils pinyinFromNSString:alias1] uppercaseString];
            }
            else
            {
                obj1_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj1 objectForKey:@"name"]] uppercaseString];
            }
        }
        else
        {
            obj1_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj1 objectForKey:@"name"]] uppercaseString];
        }
        
        if (alias2) {
            if (![alias2 isEqual:[NSNull null]]) {
                obj2_py = [[CommonUtils pinyinFromNSString:alias2] uppercaseString];
            }
            else
            {
                obj2_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj2 objectForKey:@"name"]] uppercaseString];
            }
        }
        else
        {
            obj2_py = [[CommonUtils pinyinFromNSString:(NSString*)[obj2 objectForKey:@"name"]] uppercaseString];
        }

        NSInteger result = [obj1_py compare:obj2_py];
        return result;
    };
    [friends sortUsingComparator:cmptor];
}

- (void) insertToFriendTable:(NSArray *)friends
{
    //    NSString* path = [NSString stringWithFormat:@"%@/db",user.userid];
    NSLog(@"insertToFriendTable begin");
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:DB_path];
    for (NSDictionary* friend in friends) {
        NSString* friendEmail = [friend objectForKey:@"email"];
        NSNumber* friendID = [friend objectForKey:@"id"];
        NSNumber* friendGender = [friend objectForKey:@"gender"];
        NSString* friendName = [friend objectForKey:@"name"];
        NSString* friendAlias = [self.alias_dic objectForKey:[NSString stringWithFormat:@"%@",friendID]];
        
//        NSLog(@"insert friends to database.\n email: %@, id: %@, gender: %@, name: %@, alias: %@",friendEmail,friendID,friendGender,friendName, friendAlias);
        
        NSArray* columns = [[NSArray alloc]initWithObjects:@"'id'",@"'name'",@"'email'",@"'gender'",@"'alias'", nil];
        NSArray* values;
        if (friendAlias == nil || [friendAlias isEqual:[NSNull null]]) {
            values = [[NSArray alloc]initWithObjects:
                      [NSString stringWithFormat:@"%@",friendID],
                      [NSString stringWithFormat:@"'%@'",friendName],
                      [NSString stringWithFormat:@"'%@'",friendEmail],
                      [NSString stringWithFormat:@"%@",friendGender],
                      [NSString stringWithFormat:@"%@",friendAlias], nil];
        }
        else
        {
            values = [[NSArray alloc]initWithObjects:
                      [NSString stringWithFormat:@"%@",friendID],
                      [NSString stringWithFormat:@"'%@'",friendName],
                      [NSString stringWithFormat:@"'%@'",friendEmail],
                      [NSString stringWithFormat:@"%@",friendGender],
                      [NSString stringWithFormat:@"'%@'",friendAlias], nil];
        }
        [sql insertToTable:@"friend" withColumns:columns andValues:values];
    }
    [sql closeMyDB];
    
    NSLog(@"好友列表更新完成！");
    NSLog(@"insertToFriendTable end");
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


-(void)getAliasFromServer
{
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid, @"id",
                              [NSNumber numberWithInt:ALIAS_GET], @"operation",nil];
    NSLog(@"get alias json: %@",json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    
    void(^getAliasDone)(NSData*) = ^(NSData* rData)
    {
        
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"获取备注名，收到的rData为空");
            return;
        }
        NSLog(@"received alias: %@",temp);
        NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSInteger cmd = [[response1 valueForKey:@"cmd"]integerValue];
        switch (cmd) {
            case NORMAL_REPLY:
            {
                if (!self.alias_dic) {
                    self.alias_dic = [[NSMutableDictionary alloc]init];
                }
                [self.alias_dic removeAllObjects];
                NSMutableArray* alias_list = [response1 objectForKey:@"list"];
                for (NSDictionary* temp in alias_list) {
                    NSString* fid = [NSString stringWithFormat:@"%@",[temp objectForKey:@"id"]];
                    NSString* alias = [temp objectForKey:@"alias"];
                    [self.alias_dic setValue:alias forKey:fid];
                }
            }
                break;
                
            default:
                break;
        }
        NSLog(@"get alias from server, alias_dic: %@",self.alias_dic);
        [self synchronizeFriends];
    };
    
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:ALIAS_OPERATION finshedBlock:getAliasDone];
}

-(void)getAliasFromDB
{
    [self.alias_dic removeAllObjects];
    NSMutableArray* friends = [self getFriendsFromDB];
    for (NSDictionary* friend in friends) {
        NSString* fid = [friend objectForKey:@"id"];
        NSString* alias = [friend objectForKey:@"alias"];
        [self.alias_dic setValue:alias forKey:fid];
        NSLog(@"alias from db: %@ (%@) --- %@ (%@)", fid, [fid class], alias, [alias class]);
    }
//    NSLog(@"get alias from db: %@",alias_dic);
}

-(void)updateAliasInDB
{
    NSArray* keys = [self.alias_dic allKeys];
    MySqlite* sql = [[MySqlite alloc]init];
    [sql openMyDB:DB_path];
    for (int i = 0; i < keys.count; i++) {
        NSNumber* fid = [CommonUtils NSNumberWithNSString:keys[i]];
        NSString* alias = [self.alias_dic objectForKey:keys[i]];
        NSDictionary* wheres = [CommonUtils packParamsInDictionary:
                                fid, @"id",nil];
        NSDictionary* sets;
        if (alias == nil || [alias isEqual:[NSNull null]]) {
            sets = [CommonUtils packParamsInDictionary:
                    [NSString stringWithFormat:@"%@", alias],@"alias",nil];
        }
        else
        {
            sets = [CommonUtils packParamsInDictionary:
               [NSString stringWithFormat:@"'%@'", alias],@"alias",nil];
        }
        [sql updateDataWitTableName:@"friend" andWhere:wheres andSet:sets];
    }
    [sql closeMyDB];
    NSLog(@"更新好友备注名完成");
}

-(void)insertAliasToFriendList
{
    NSLog(@"before insert alias to friendlist, alias: %@", self.alias_dic);
    for (int i = 0; i < friendList.count; i++) {
//        NSMutableDictionary* friend1 = [[NSMutableDictionary alloc]initWithDictionary:friend];
        NSMutableDictionary* friend = [friendList objectAtIndex:i];
        NSNumber* fid = [friend objectForKey:@"id"];
       
        NSString* alias = [self.alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
        NSLog(@"fid: %@, alias: %@",fid, alias);
        if (alias) {
            [friend setValue:alias forKey:@"alias"];
        }
        else
        {
            [friend setValue:[NSNull null] forKey:@"alias"];
        }
    }
    NSLog(@"after insert alias to friendlist: %@",self.friendList);
}

-(void)aliasDicDidChanged
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       [self updateAliasInDB];
                   });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
//                       for (NSMutableDictionary* aFriend in self.friendList) {
//                           NSNumber* friend_id = [aFriend objectForKey:@"id"];
//                           if ([friend_id isEqualToNumber:fid1]) {
//                               [aFriend setValue:alias1 forKey:@"alias"];
//                               break;
//                           }
//                       }
                       [self insertAliasToFriendList];
                       [self friendListDidChanged];
                       
                   });

}



//============================================================================
#pragma mark - Init Notification Messages
//================================Init Notification Messages=====================

- (void) getMsgFromDataBase
{
    NSLog(@"getMsgFromDataBase begin");
    [self.eventRequestMsg removeAllObjects];
    [self.friendRequestMsg removeAllObjects];
    [self.systemMsg removeAllObjects];
    [self.historicalMsg removeAllObjects];
    MySqlite* mySql = [[MySqlite alloc]init];
    [mySql openMyDB:DB_path];
    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq",@"ishandled", nil] andWhere:nil];
    [mySql closeMyDB];
    NSLog(@"msg count: %d \nmsg from db: %@",msgFromDB.count, msgFromDB);
    //    [self.notificationsTable reloadData];
    NSInteger count = self.msgFromDB.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        NSDictionary* msg = [msgFromDB objectAtIndex:i];
        NSString* msg_str = [msg objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
        NSNumber* seq = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"seq"]];
        NSNumber* ishandled = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"ishandled"]];
//        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
//            NSLog(@"seq is string");
//        }
//        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
//        {
//            NSLog(@"seq is number");
//        }

        
        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
        [msg_dic setValue:ishandled forKey:@"ishandled"];
        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
        if ([ishandled integerValue] == -1) {
            switch (cmd) {
                case ADD_FRIEND_NOTIFICATION:
                case ADD_FRIEND_RESULT:
                {
                    [self.friendRequestMsg addObject:msg_dic];
                }
                    break;
                case EVENT_INVITE_RESPONSE:
                case REQUEST_EVENT_RESPONSE:
                case QUIT_EVENT_NOTIFICATION:
                case KICK_EVENT_NOTIFICATION:
                {
                    [self.systemMsg addObject:msg_dic];
                }
                    break;
                case NEW_EVENT_NOTIFICATION:
                case REQUEST_EVENT:
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
//    [self performSelectorOnMainThread:@selector(getMsgFromDataBaseDone) withObject:nil waitUntilDone:YES];
    NSLog(@"getMsgFromDataBase end");
}

-(void)getMsgFromDataBaseDone
{
    self.hasInitNotification = YES;
}


//===============================================================================

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSLog(@"服务器返回了消息");
    [synchronizeFriendTimer invalidate];
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
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
                    [self.friendList removeAllObjects];
                    for (NSMutableDictionary* friend in tempFriends) {
                        NSMutableDictionary* friend1 = [[NSMutableDictionary alloc]initWithDictionary:friend];
                        [self.friendList addObject:friend1];
                    }
                    [self insertAliasToFriendList];
                    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:self.friendList];
                    [thread start];
                }
                else
                {
                    NSLog(@"好友列表已经是最新的啦～");
                    dispatch_async(dispatch_get_global_queue(0, 0), ^
                                   {
                                       [self insertAliasToFriendList];
                                       [self updateAliasInDB];
                                   });
                    
//                    self.friendList = [self getFriendsFromDB];
//                    self.sortedFriendDic = [self sortFriendList];
                }
                NSLog(@"synchronize friends: %@",friendList);
                dispatch_async(dispatch_get_global_queue(0, 0), ^
                               {
                                   [self friendListDidChanged];
                                   dispatch_async(dispatch_get_main_queue(), ^
                                                  {
                                                      doingSynchronizeFriend = NO;
                                                      synchronizeFriendDone = YES;
                                                  });
                               });
            }
            else
            {
                NSLog(@"不是同步好友的操作");
            }
            
            
            
        }
            break;
        default:
        {
            
            //[CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
    }
    getSynchronizeFriendResponse = YES;
}


@end
