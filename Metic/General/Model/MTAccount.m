//
//  MTAccount.m
//  WeShare
//
//  Created by 俊健 on 15/12/2.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTAccount.h"
#import "FXKeychain.h"

#pragma mark KeyChain Configuration
static NSString * const MTACCOUNT_KEYCHAIN = @"MTAccount20151202";

@implementation MTAccount

@synthesize email;
@synthesize phoneNumber;
@synthesize password;
@synthesize openId;
@synthesize type;
@synthesize hadCompleteInfo;

+ (MTAccount *)singleInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        [self loadAccount];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        email = [aDecoder decodeObjectForKey:@"email"];
        phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
        password = [aDecoder decodeObjectForKey:@"password"];
        openId = [aDecoder decodeObjectForKey:@"openId"];
        type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        hadCompleteInfo = [[aDecoder decodeObjectForKey:@"hadCompleteInfo"] boolValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.openId forKey:@"openId"];
    [aCoder encodeObject:@(self.type) forKey:@"type"];
    [aCoder encodeObject:@(self.hadCompleteInfo) forKey:@"hadCompleteInfo"];
}

+ (BOOL)isExist
{
    return ([FXKeychain defaultKeychain][MTACCOUNT_KEYCHAIN] != nil);
}

- (void)loadAccount
{
    [FXKeychain defaultKeychain].accessibility = FXKeychainAccessibleAlwaysThisDeviceOnly;
    MTAccount *account = [FXKeychain defaultKeychain][MTACCOUNT_KEYCHAIN];
    self.email = account.email;
    self.phoneNumber = account.phoneNumber;
    self.password = account.password;
    self.openId = account.openId;
    self.type = account? account.type:MTAccountTypeEmpty;
    self.hadCompleteInfo = account.hadCompleteInfo;
}

- (void)saveAccount
{
    [FXKeychain defaultKeychain][MTACCOUNT_KEYCHAIN] = self;
}

- (void)deleteAccount {
    email = nil;
    phoneNumber = nil;
    password = nil;
    openId = nil;
    type = MTAccountTypeEmpty;
    
    [[FXKeychain defaultKeychain] removeObjectForKey:MTACCOUNT_KEYCHAIN];
    
//    [[FXKeychain defaultKeychain] removeObjectForKey:EMAIL_KEYCHAIN];
//    [[FXKeychain defaultKeychain] removeObjectForKey:PHONE_NUMBER_KEYCHAIN];
//    [[FXKeychain defaultKeychain] removeObjectForKey:PASSWORD_KEYCHAIN];
//    [[FXKeychain defaultKeychain] removeObjectForKey:OPENID_KEYCHAIN];
//    [FXKeychain defaultKeychain][TYPE_KEYCHAIN] = @(MTAccountTypeEmpty);
}

@end
