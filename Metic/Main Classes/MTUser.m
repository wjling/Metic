//
//  MTUser.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTUser.h"
#import "../Utils/PhotoGetter.h"


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
        self.friendIds = [[NSMutableSet alloc]init];
        self.friendList = [[NSMutableArray alloc]initWithCapacity:0];
        self.sortedFriendDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.sectionArray = [[NSMutableArray alloc]initWithCapacity:0];
//        self.sql = [[MySqlite alloc]init];
        self.wait = 0.1;
    }
    return self;
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

//-(void)updateAvatarList
//{
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//    [dictionary setValue:self.userid  forKey:@"id"];
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//    [httpSender sendMessage:jsonData withOperationCode:GET_AVATAR_UPDATETIME];
//    
//}

//-(void)updateAvatar
//{
//    self.sql = [[MySqlite alloc]init];
//    NSString * path = [NSString stringWithFormat:@"%@/db",self.userid];
//    [self.sql openMyDB:path];
//    for (NSDictionary *dictionary in self.avatarInfo) {
//        [self.friendIds addObject:[dictionary valueForKey:@"id"]];
//        NSArray *seletes = [[NSArray alloc]initWithObjects:@"updatetime", nil];
//        NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[dictionary valueForKey:@"id"],@"id", nil];
//        NSMutableArray *results = [self.sql queryTable:@"avatar" withSelect:seletes andWhere:wheres];
//        if (!results.count) {
//            NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
//            NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
//            [self.sql insertToTable:@"avatar" withColumns:columns andValues:values];
//        }else{
//            NSDictionary* result = results[0];
//            NSString *local_update = [result valueForKey:@"updatetime"];
//            NSString *net_update = [dictionary valueForKey:@"updatetime"];
//            if (![local_update isEqualToString:net_update]) {
//                NSArray *columns = [[NSArray alloc]initWithObjects:@"'id'",@"'updatetime'", nil];
//                NSArray *values = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]],[NSString stringWithFormat:@"'%@'",[dictionary valueForKey:@"updatetime"]], nil];
//                [self.sql insertToTable:@"avatar" withColumns:columns andValues:values];
//                PhotoGetter *getter = [[PhotoGetter alloc]initWithData:nil path:[NSString stringWithFormat:@"/avatar/%@.jpg",[MTUser sharedInstance].userid] type:2 cache:[MTUser sharedInstance].avatar];
//                [getter updatePhoto];
//            }
//        }
//    }
//    [self.sql closeMyDB];
//}

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
    [sql createTableWithTableName:@"notification" andIndexWithProperties:@"seq INTEGER PRIMARY KEY UNIQUE",@"timestamp",@"msg",nil];
    [sql createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",nil];
    [sql createTableWithTableName:@"avatar" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"updatetime",@"url",nil];
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

//======================================SYNCHRONIZE FRIENDS=================================

- (void) synchronizeFriends
{
    self.friendList = [self getFriendsFromDB];
    NSLog(@"get friends from DB, friendList: %@",self.friendList);
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          self.userid,@"id",
                          [NSNumber numberWithInteger:self.friendList.count],@"friends_number",nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];
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
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
    //    NSLog(@"friendlist count: %d",friendList.count);
    for (NSMutableDictionary* aFriend in self.friendList) {
        NSString* fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
        //        NSLog(@"friend name: %@",fname_py);
        NSString* first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
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
            [self.sectionArray addObject:[first_letter uppercaseString]];
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
    [sorted setObject:temp_arr forKey:@"🍎"];
    
    [sectionArray insertObject:@"🍎" atIndex:0];
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


//============================================================================



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
            self.avatarInfo = [response1 valueForKey:@"list"];
            //[self updateAvatar];NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            if (tempFriends) {
                if (tempFriends.count) {
                    self.friendList = tempFriends;
                    self.sortedFriendDic = [self sortFriendList];
                    //                [self insertToFriendTable:tempFriends];
                    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(insertToFriendTable:) object:tempFriends];
                    
                    [thread start];
                    
                }
                else
                {
                    NSLog(@"好友列表已经是最新的啦～");
//                    self.friendList = [self getFriendsFromDB];
                    self.sortedFriendDic = [self sortFriendList];
                    
                }
                NSLog(@"synchronize friends: %@",friendList);
                
            }
            
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
