//
//  MTUser.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTUser.h"
#import "PhotoGetter.h"
#import "SDImageCache.h"
#import "XGPush.h"
#import "AppDelegate.h"
#import "MTDatabaseHelper.h"
#import "MTOperation.h"
#import "MegUtils.h"
#import "MTPushMessageHandler.h"
#import "MenuViewController.h"


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
        self.friendList = [[NSMutableArray alloc]initWithCapacity:0];
        self.sortedFriendDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.sectionArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.alias_dic = [[NSMutableDictionary alloc]init];
        self.friendsIdSet = [[NSMutableSet alloc]init];
        self.updateEventStatus = [[NSMutableDictionary alloc]init];
        self.updatePVStatus = [[NSMutableDictionary alloc]init];
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
    MTLOG(@"getInfo:\n%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_USER_INFO finshedBlock:^(NSData *rData) {
        if (!rData) return ;
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableContainers error:nil];
        MTLOG(@"getInfo result:\n%@",response1);
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                if ([response1 valueForKey:@"name"]) {//更新用户信息
                    [[MTUser sharedInstance] initWithData:response1];
                    [[MenuViewController sharedInstance] refresh];
                }
            }
        }
    }];
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
//                    MTLOG(@"%@",_avatarInfo);
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
    for (NSInteger i = 0;i < self.avatarInfo.count; i++) {
        NSDictionary *dictionary = [self.avatarInfo objectAtIndex:i];
        NSArray *seletes = [[NSArray alloc]initWithObjects:@"updatetime", nil];
        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[dictionary valueForKey:@"id"],@"id", nil];
        [[MTDatabaseHelper sharedInstance] queryTable:@"avatar" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
            NSMutableArray *results = resultsArray;
            if (!results.count) {
                NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
                NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
                [[MTDatabaseHelper sharedInstance]insertToTable:@"avatar" withColumns:columns andValues:values];
            }else{
                NSDictionary* result = results[0];
                NSString *local_update = [result valueForKey:@"updatetime"];
                NSString *net_update = [dictionary valueForKey:@"updatetime"];
                if (![local_update isEqualToString:net_update]) {
                    NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
                    NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
                    [[MTDatabaseHelper sharedInstance]insertToTable:@"avatar" withColumns:columns andValues:values];
                    
                    
                    NSString*path = [MegUtils avatarImagePathWithUserId:dictionary[@"id"]];
                    [[SDImageCache sharedImageCache] removeImageForKey:path];
                    
                    NSString*path_HD = [MegUtils avatarHDImagePathWithUserId:dictionary[@"id"]];
                    [[SDImageCache sharedImageCache] removeImageForKey:path_HD];

                }
            }
        }];
    }
}

- (void)setUid:(NSNumber*) user_id
{
    userid = user_id;
    [MTDatabaseHelper refreshDatabaseFile];
    [self initUserDir];
    
    NSString *account = [NSString stringWithFormat:@"%@_hdb",[MTUser sharedInstance].userid];
    [XGPush setAccount:account];
    
    [MTPushMessageHandler registerPush];
    
    [self systemSettingsInit:user_id];
    [self getAliasFromDB];
    [self getAliasFromServer];
    [NSThread detachNewThreadSelector:@selector(getMsgFromDataBase) toTarget:self withObject:nil];
//    [NSThread detachNewThreadSelector:@selector(systemSettingsInit:) toTarget:self withObject:user_id];
    
//    //同步推送消息
//    MTLOG(@"开始同步消息");
//    void(^synchronizeDone)(NSNumber*, NSNumber*) = ^(NSNumber* min_seq, NSNumber* max_seq)
//    {
//        if (!min_seq || !max_seq) {
//            return;
//        }
//        [MTPushMessageHandler pullAndHandlePushMessageWithMinSeq:min_seq andMaxSeq:max_seq andCallBackBlock:nil];
//    };
//    [MTPushMessageHandler synchronizePushSeqAndCallBack:synchronizeDone];
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
      
        MTLOG(@"init user DB");
        [self performSelectorOnMainThread:@selector(initUserDB) withObject:nil waitUntilDone:YES];
    }
    else
    {
        
        NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
        NSString* version = [userDfs objectForKey:[NSString stringWithFormat:@"%@DB_version",self.userid]];
        int result;
        if (!version) {
            version = @"0.0.0";
            MTLOG(@"升级数据库，添加所有补丁");
            //设置临时版本号0.0.0 让它加载下面的补丁
        }
        
        
        result = [CommonUtils compareVersion1:version andVersion2:@"0.1.18"];
        
        if (result == -1) {
            MTLOG(@"升级数据库，原数据库版本：%@",version);
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"friend" addsColumn:@"alias" withDefault:nil];

        }
        
        result = [CommonUtils compareVersion1:version andVersion2:@"1.0.3"];
        
        if (result <= 0) {
            MTLOG(@"升级数据库，原数据库版本：%@",version);
            [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"uploadIMGtasks" indexesWithProperties:@[@"id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"imgName",@"alasset"]];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"uploadIMGtasks" addsColumn:@"width" withDefault:nil];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"uploadIMGtasks" addsColumn:@"height" withDefault:nil];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"beginTime" withDefault:nil];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"joinTime" withDefault:nil];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"updateTime" withDefault:nil];
            
        }
        
        result = [CommonUtils compareVersion1:version andVersion2:@"1.1.0"];
        
        if (result <= 0) {
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"updateTime" withDefault:nil];
        }
        
        result = [CommonUtils compareVersion1:version andVersion2:@"1.1.2"];
        
        if (result <= 0) {
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"islike" withDefault:nil];
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"event" addsColumn:@"likeTime" withDefault:nil];
        }
        
        result = [CommonUtils compareVersion1:version andVersion2:@"1.2.0"];
        
        if (result <= 0) {
            [[MTDatabaseHelper sharedInstance] addsColumntoTable:@"uploadIMGtasks" addsColumn:@"imageDescription" withDefault:nil];
        }
        
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [userDfs setObject:version forKey:[NSString stringWithFormat:@"%@DB_version",self.userid]];
        [userDfs synchronize];
    }
}

- (void)initUserDB
{
    MTLOG(@"初始化数据库");
    NSUserDefaults* userDfs = [NSUserDefaults standardUserDefaults];
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [userDfs setObject:version forKey:[NSString stringWithFormat:@"%@DB_version",self.userid]];
    [userDfs synchronize];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"event" indexesWithProperties:@[@"event_id INTEGER PRIMARY KEY UNIQUE",@"beginTime",@"joinTime",@"updateTime",@"likeTime",@"islike",@"event_info"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"notification" indexesWithProperties:@[@"seq INTEGER PRIMARY KEY UNIQUE",@"timestamp",@"msg",@"ishandled"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"friend" indexesWithProperties:@[@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",@"alias"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"avatar" indexesWithProperties:@[@"id INTEGER PRIMARY KEY UNIQUE",@"updatetime"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"eventPhotos" indexesWithProperties:@[@"photo_id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"photoInfo"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"eventVideo" indexesWithProperties:@[@"video_id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"videoInfo"]];
    
    [[MTDatabaseHelper sharedInstance] createTableWithTableName:@"uploadIMGtasks" indexesWithProperties:@[@"id INTEGER PRIMARY KEY UNIQUE",@"event_id",@"imgName",@"alasset",@"imageDescription",@"width",@"height"]];
}

- (void)initWithData:(NSDictionary *)mdictionary
{
    self.userid = [mdictionary objectForKey:@"id"] != [NSNull null]? [mdictionary objectForKey:@"id"]:nil;
    self.name = [mdictionary objectForKey:@"name"] != [NSNull null]? [mdictionary objectForKey:@"name"]:nil;
    self.gender = [mdictionary objectForKey:@"gender"] != [NSNull null]? [mdictionary objectForKey:@"gender"]:nil;
    self.sign = [mdictionary objectForKey:@"sign"] != [NSNull null]? [mdictionary objectForKey:@"sign"]:nil;
    self.phone = [mdictionary objectForKey:@"phone"] != [NSNull null]? [mdictionary objectForKey:@"phone"]:nil;
    self.location = [mdictionary objectForKey:@"location"] != [NSNull null]? [mdictionary objectForKey:@"location"]:nil;
    self.email = [mdictionary objectForKey:@"email"] != [NSNull null]? [mdictionary objectForKey:@"email"]:nil;
    [MTUser saveUser];
}

-(void)systemSettingsInit:(NSNumber*)uid
{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",uid]];
    if (!userSettings) {
        MTLOG(@"重置用户设置信息");
        userSettings = [[NSMutableDictionary alloc]init];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting1"];
        [userSettings setValue:[NSNumber numberWithBool:YES] forKey:@"systemSetting2"];
        [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"hasUploadPhoneNumber"];
        
        NSMutableDictionary* unRead_dic = [[NSMutableDictionary alloc]init];
        [unRead_dic setValue:[NSNumber numberWithInt:-1] forKey:@"tab_show"];
        [unRead_dic setValue:[NSNumber numberWithInt:0] forKey:@"tab_0"];
        [unRead_dic setValue:[NSNumber numberWithInt:0] forKey:@"tab_1"];
        [unRead_dic setValue:[NSNumber numberWithInt:0] forKey:@"tab_2"];
        [userSettings setValue:unRead_dic forKey:@"hasUnreadNotification1"];
        
        [userSettings setValue:[NSNumber numberWithBool:NO] forKey:@"openWithNotificationCenter"];
        [userDf setObject:userSettings forKey:[NSString stringWithFormat:@"USER%@",uid]];
        [userDf synchronize];
    }
}

//======================================SYNCHRONIZE FRIENDS=================================

- (void) synchronizeFriends
{
    MTLOG(@"synchronizeFriends begin");
    getSynchronizeFriendResponse = NO;
    doingSynchronizeFriend = YES;
    synchronizeFriendDone = NO;
    
    synchronizeFriendTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(synchronizeTimerDoing) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:synchronizeFriendTimer forMode:NSRunLoopCommonModes];
    
    [self getFriendsFromDBwithCompletion:^(NSMutableArray* results) {
        self.friendList = [NSMutableArray arrayWithArray:results];
        self.nameFromID_dic = [[NSMutableDictionary alloc]init];
        for (int i = 0; i < friendList.count; i++) {
            NSDictionary* friend = [friendList objectAtIndex:i];
            NSNumber* fid = [CommonUtils NSNumberWithNSString:[friend objectForKey:@"id"]];
            NSString* fname = [friend objectForKey:@"name"];
            //        [friend setValue:fid forKey:@"id"];
            [friendsIdSet addObject:fid];
            [nameFromID_dic setValue:fname forKey:[NSString stringWithFormat:@"%@",fid]];
        }
        //    MTLOG(@"get friends from DB, friendList: %@",self.friendList);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* json = [CommonUtils packParamsInDictionary:
                                  self.userid,@"id",
                                  [NSNumber numberWithInteger:self.friendList.count],@"friends_number",nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
            HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
            [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];
            MTLOG(@"synchronize friend json: %@",json);
            MTLOG(@"synchronizeFriends end");
        });
        
    }];
    
}

-(void)synchronizeTimerDoing
{
    doingSynchronizeFriend = NO;
}

- (void)getFriendsFromDBwithCompletion:(void (^)(NSMutableArray* results))block
{

    [[MTDatabaseHelper sharedInstance] queryTable:@"friend" withSelect:@[@"*"] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        NSMutableArray* friends = resultsArray;
        if (block) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(friends);
            });
        }
        MTLOG(@"getFriendsFromDB: %@", friends);

    }];
}

- (NSMutableDictionary*)sortFriendList
{
    doingSortingFriends = YES;
    sortingFriendsDone = NO;
    BOOL hasSpecialChar = NO;
    NSMutableArray* sectionArr = [[NSMutableArray alloc]initWithCapacity:0];
//    [self.sectionArray removeAllObjects];
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
//    MTLOG(@"before sort, friendlist: %@",friendList);
    for (int i = 0; i < self.friendList.count; i++) {
        NSMutableDictionary* aFriend  = [self.friendList objectAtIndex:i];
        NSString* fAlias = [aFriend objectForKey:@"alias"];
        NSString* fname_py;
//        MTLOG(@"alias: %@----%@",fAlias,[fAlias class]);
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
//        MTLOG(@"friend name: %@",fname_py);
        NSString *regex = @"[a-zA-Z]";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        NSString* first_letter;
        if (fname_py && ![fname_py isEqualToString:@""]) {
            first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
        }
        else
        {
            fname_py = @"无";
        }
        BOOL isSpecialChar = ! [predicate evaluateWithObject:first_letter];
        if (isSpecialChar) {
            first_letter = @"#";
            hasSpecialChar = YES;
        }
        NSMutableArray* groupOfFriends = [sorted objectForKey:[first_letter uppercaseString]];
        
        if (groupOfFriends) {
            [groupOfFriends addObject:aFriend];
//            MTLOG(@"a friend: %@",aFriend);
        }
        else
        {
            groupOfFriends = [[NSMutableArray alloc]init];
            [groupOfFriends addObject:aFriend];
            [sorted setObject:groupOfFriends forKey:[first_letter uppercaseString]];
            if (!isSpecialChar) {
                [sectionArr addObject:[first_letter uppercaseString]];
            }
            
        }
    }
    
    for (NSInteger i = 0; i < sectionArr.count; i++) {
        NSString* key = [sectionArr objectAtIndex:i];
        NSMutableArray* arr = [sorted objectForKey:key];
        [self rankFriendsInArray:arr];
//        MTLOG(@"sorted array: %@",arr);
    }
    [sectionArr sortUsingComparator:^(id obj1, id obj2)
     {
         return [(NSString*)obj1 compare:(NSString*)obj2];
     }];
    
    NSDictionary* temp_dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"好友推荐",@"name", nil];
    NSArray* temp_arr = [[NSArray alloc]initWithObjects:temp_dic, nil];
    [sorted setObject:temp_arr forKey:@"★"];
    
    [sectionArr insertObject:@"★" atIndex:0];
    if (hasSpecialChar) {
        [sectionArr addObject:@"#"];
    }
    self.sectionArray = sectionArr;
//    MTLOG(@"sorted friends dictionary: %@",sorted);
//    MTLOG(@"section array: %@",self.sectionArray);
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
    MTLOG(@"insertToFriendTable begin");
    [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"friend" withWhere:nil];
    for (int i = 0; i < friends.count; i++) {
        NSDictionary* friend = [friends objectAtIndex:i];
        NSString* friendEmail = [friend objectForKey:@"email"];
        NSNumber* friendID = [friend objectForKey:@"id"];
        NSNumber* friendGender = [friend objectForKey:@"gender"];
        NSString* friendName = [friend objectForKey:@"name"];
        NSString* friendAlias = [self.alias_dic objectForKey:[NSString stringWithFormat:@"%@",friendID]];
        
//        MTLOG(@"insert friends to database.\n email: %@, id: %@, gender: %@, name: %@, alias: %@",friendEmail,friendID,friendGender,friendName, friendAlias);
        
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
        [[MTDatabaseHelper sharedInstance] insertToTable:@"friend" withColumns:columns andValues:values];
    }
    MTLOG(@"好友列表更新完成！");
    MTLOG(@"insertToFriendTable end");
}

-(void)friendListDidChanged
{
    self.sortedFriendDic = [self sortFriendList];
    
    for (int i = 0; i < friendList.count; i++) {
        NSDictionary* friend = [friendList objectAtIndex:i];
        NSNumber* fid = [CommonUtils NSNumberWithNSString:[friend objectForKey:@"id"]];
        NSString* fname = [friend valueForKey:@"name"];
        [friendsIdSet addObject:fid];
        [nameFromID_dic setValue:fname forKey:[NSString stringWithFormat:@"%@",fid]];
    }
//    MTLOG(@"friend id set: %@",friendsIdSet);
}


-(void)getAliasFromServer
{
    
    NSDictionary* json_dic = [CommonUtils packParamsInDictionary:
                              [MTUser sharedInstance].userid, @"id",
                              [NSNumber numberWithInt:ALIAS_GET], @"operation",nil];
    MTLOG(@"get alias json: %@",json_dic);
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    
    void(^getAliasDone)(NSData*) = ^(NSData* rData)
    {
        
        NSString* temp = @"";
        if (rData) {
            temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        }
        else
        {
            MTLOG(@"获取备注名，收到的rData为空");
            return;
        }
        MTLOG(@"received alias: %@",temp);
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
                for (NSInteger i = 0; i <alias_list.count; i++) {
                    NSDictionary* temp = [alias_list objectAtIndex:i];
                    NSString* fid = [NSString stringWithFormat:@"%@",[temp objectForKey:@"id"]];
                    NSString* alias = [temp objectForKey:@"alias"];
                    [self.alias_dic setValue:alias forKey:fid];
                }
            }
                break;
                
            default:
                break;
        }
//        MTLOG(@"get alias from server, alias_dic: %@",self.alias_dic);
        [self synchronizeFriends];
    };
    
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:ALIAS_OPERATION finshedBlock:getAliasDone];
}

-(void)getAliasFromDB
{
    [self.alias_dic removeAllObjects];
//    NSMutableArray* friends = [self getFriendsFromDB];
    [self getFriendsFromDBwithCompletion:^(NSMutableArray *results) {
        NSMutableArray* friends = [NSMutableArray arrayWithArray:results];
        for (int i = 0; i < friends.count; i++) {
            NSDictionary* friend = [friends objectAtIndex:i];
            NSString* fid = [NSString stringWithFormat:@"%@",[friend objectForKey:@"id"]];
            NSString* alias = [friend objectForKey:@"alias"];
            [self.alias_dic setValue:alias forKey:fid];
        }

    }];
}

-(void)updateAliasInDB
{
    NSArray* keys = [self.alias_dic allKeys];
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
        [[MTDatabaseHelper sharedInstance]updateDataWithTableName:@"friend" andWhere:wheres andSet:sets];
    }
    MTLOG(@"更新好友备注名完成");
}

-(void)insertAliasToFriendList
{
//    MTLOG(@"before insert alias to friendlist, alias: %@", self.alias_dic);
    for (int i = 0; i < friendList.count; i++) {
//        NSMutableDictionary* friend1 = [[NSMutableDictionary alloc]initWithDictionary:friend];
        NSMutableDictionary* friend = [[NSMutableDictionary alloc]initWithDictionary:[friendList objectAtIndex:i]];
        NSNumber* fid = [friend objectForKey:@"id"];
       
        NSString* alias = [self.alias_dic objectForKey:[NSString stringWithFormat:@"%@",fid]];
//        MTLOG(@"fid: %@, alias: %@",fid, alias);
        if (alias) {
            [friend setValue:alias forKey:@"alias"];
        }
        else
        {
            [friend setValue:[NSNull null] forKey:@"alias"];
        }
        [friendList replaceObjectAtIndex:i withObject:friend];
    }
//    MTLOG(@"after insert alias to friendlist: %@",self.friendList);
}

-(void)aliasDicDidChanged
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^
    {
        [self updateAliasInDB];
    });
    
    [self insertAliasToFriendList];
    [self friendListDidChanged];
}



//============================================================================
#pragma mark - Init Notification Messages
//================================Init Notification Messages=====================

- (void) getMsgFromDataBase
{
    MTLOG(@"getMsgFromDataBase begin");
    [self.eventRequestMsg removeAllObjects];
    [self.friendRequestMsg removeAllObjects];
    [self.systemMsg removeAllObjects];
    [self.historicalMsg removeAllObjects];
//    [mySql openMyDB:DB_path];
//    self.msgFromDB = [mySql queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq",@"ishandled", nil] andWhere:nil];
//    [mySql closeMyDB];
////    MTLOG(@"msg count: %d \nmsg from db: %@",msgFromDB.count, msgFromDB);
//    //    [self.notificationsTable reloadData];
//    NSInteger count = self.msgFromDB.count;
//    for (NSInteger i = count - 1; i >= 0; i--) {
//        NSDictionary* msg = [msgFromDB objectAtIndex:i];
//        NSString* msg_str = [msg objectForKey:@"msg"];
//        NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
//        NSNumber* seq = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"seq"]];
//        NSNumber* ishandled = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"ishandled"]];
////        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
////            MTLOG(@"seq is string");
////        }
////        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
////        {
////            MTLOG(@"seq is number");
////        }
//
//        
//        [msg_dic setValue:seq forKey:@"seq"]; //将seq放进消息里
//        [msg_dic setValue:ishandled forKey:@"ishandled"];
//        NSInteger cmd = [[msg_dic objectForKey:@"cmd"] intValue];
//        if ([ishandled integerValue] == -1) {
//            switch (cmd) {
//                case ADD_FRIEND_NOTIFICATION:
//                case ADD_FRIEND_RESULT:
//                {
//                    [self.friendRequestMsg addObject:msg_dic];
//                }
//                    break;
//                case EVENT_INVITE_RESPONSE:
//                case REQUEST_EVENT_RESPONSE:
//                case QUIT_EVENT_NOTIFICATION:
//                case KICK_EVENT_NOTIFICATION:
//                {
//                    [self.systemMsg addObject:msg_dic];
//                }
//                    break;
//                case NEW_EVENT_NOTIFICATION:
//                case REQUEST_EVENT:
//                {
//                    [self.eventRequestMsg addObject:msg_dic];
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//        }
//        else
//        {
//            [self.historicalMsg addObject:msg_dic];
//        }
//    }
    [[MTDatabaseHelper sharedInstance] queryTable:@"notification" withSelect:[[NSArray alloc]initWithObjects:@"msg",@"seq",@"ishandled", nil] andWhere:nil completion:^(NSMutableArray *resultsArray) {
        self.msgFromDB = resultsArray;
        NSInteger count = self.msgFromDB.count;
        for (NSInteger i = count - 1; i >= 0; i--) {
            NSDictionary* msg = [msgFromDB objectAtIndex:i];
            NSString* msg_str = [msg objectForKey:@"msg"];
            NSMutableDictionary* msg_dic = [[NSMutableDictionary alloc]initWithDictionary:[CommonUtils NSDictionaryWithNSString:msg_str]];
            NSNumber* seq = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"seq"]];
            NSNumber* ishandled = [CommonUtils NSNumberWithNSString:(NSString *)[msg objectForKey:@"ishandled"]];
            //        if ([[msg objectForKey:@"seq"] isKindOfClass:[NSString class]]) {
            //            MTLOG(@"seq is string");
            //        }
            //        else if ([[msg objectForKey:@"seq"] isKindOfClass:[NSNumber class]])
            //        {
            //            MTLOG(@"seq is number");
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
                    case SYSTEM_PUSH:
                    {
                        [self.systemMsg addObject:msg_dic];
                    }
                        break;
                    case NEW_EVENT_NOTIFICATION:
                    case REQUEST_EVENT:
                    case CHANGE_EVENT_INFO_NOTIFICATION:
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

    }];

    //    MTLOG(@"msg count: %d \nmsg from db: %@",msgFromDB.count, msgFromDB);
    //    [self.notificationsTable reloadData];
    
    
//    self.hasInitNotification = YES;
//    [self performSelectorOnMainThread:@selector(getMsgFromDataBaseDone) withObject:nil waitUntilDone:YES];
    MTLOG(@"getMsgFromDataBase end");
}

-(void)getMsgFromDataBaseDone
{
    self.hasInitNotification = YES;
}


//===============================================================================

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    MTLOG(@"服务器返回了消息");
    [synchronizeFriendTimer invalidate];
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"received Data: %@",temp);
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
//                    [self.friendList removeAllObjects];
                    NSMutableArray* temp_friendlist = [[NSMutableArray alloc]init];
                    for (int i = 0; i < tempFriends.count; i++) {
                        NSDictionary* friend = [tempFriends objectAtIndex:i];
                        NSMutableDictionary* friend1 = [[NSMutableDictionary alloc]initWithDictionary:friend];
                        [temp_friendlist addObject:friend1];
                    }
                    self.friendList = temp_friendlist;
                    [self insertAliasToFriendList];
                    NSArray* backupFriendList = [[NSArray alloc]initWithArray:self.friendList copyItems:YES];
                    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:backupFriendList];
                    [thread start];
                    MTLOG(@"同步好友，从服务器得到好友列表: %@", self.friendList);
                }
                else
                {
                    MTLOG(@"好友列表已经是最新的啦～");
                    [self insertAliasToFriendList];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^
                                   {
                                       [self updateAliasInDB];
                                   });
                    
//                    self.friendList = [self getFriendsFromDB];
//                    self.sortedFriendDic = [self sortFriendList];
                }
//                MTLOG(@"synchronize friends: %@",friendList);
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
                MTLOG(@"不是同步好友的操作");
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

#pragma User Manage
+ (void)saveUser {
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance].name) {
            [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
    }
}

+ (void)loadUser {
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:MtuserPath])
        {
            NSArray* users;
            @try {
                users = [NSKeyedUnarchiver unarchiveObjectWithFile:MtuserPath];
            }
            @catch (NSException *exception) {
            }
            @finally {
                if (!users || users.count == 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self deleteUser];
                }
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self deleteUser];
        }
        
    }else{
        [self deleteUser];
    }
}

+ (void)deleteUser {
    MTUser *user = [[MTUser alloc]init];
    singletonInstance = user;
    [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
    [fileManager removeItemAtPath:MtuserPath error:nil];
}

+ (void)saveMarkers:(NSMutableArray *)markers toFilePath:(NSString *)filePath {
    [NSKeyedArchiver archiveRootObject:markers toFile:filePath];
}
@end
