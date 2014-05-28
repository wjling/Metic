//
//  AppConstants.h
//  Metis
//
//  Created by mac on 14-5-20.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#ifndef Metis_AppConstants_h
#define Metis_AppConstants_h

#import "HttpSender.h"

HttpSender* httpSender;

enum Operation_Code
{
    REGISTER = 0,
    LOGIN = 1,
    GET_USER_INFO = 2,
    GET_MY_EVENTS = 3,
    GET_EVENTS = 4,
};

enum Return_Code
{
    NORMAL_REPLY =100,
    USER_NOT_FOUND,
    LOGIN_SUC = 102,
    PASSWD_NOT_CORRECT = 103,
    GET_SALT = 104,
    USER_EXIST = 105,
    SERVER_ERROR = 106,
    ALREADY_FRIENDS = 107,
    REQUEST_FAIL = 108,
    COMMENT_NOT_EXIST = 109,
    EVENT_NOT_EXIST = 110,
    ALREADY_IN_EVENT = 111,
    DATABASE_ERROR = 112,
    NO_AVATAR = 113,
    PHOTO_NOT_EXIST = 114,
    VIDEO_NOT_EXIST = 115,
    REQUEST_DATA_ERROR = 116,
    USER_ALREADY_ONLINE = 117,
    USER_LOGOUT_SUC = 118,
};

#endif
