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

enum Server_code{
    Server = 0,//测试服
//    Server = 1,//正式服
};

enum Alias_code
{
    ALIAS_GET = 0,
    ALIAS_SET = 1,
};

enum Operation_Code
{
    REGISTER = 0,
    LOGIN = 1,
    GET_USER_INFO = 2,
    GET_MY_EVENTS = 3,
    GET_EVENTS = 4,
    ADD_FRIEND = 5,
    UPLOAD_PHONEBOOK = 6,
    SEARCH_FRIEND = 7,
    SYNCHRONIZE_FRIEND = 8,
    LAUNCH_EVENT = 9,
    PARTICIPATE_EVENT = 10,
    INVITE_FRIENDS =  11,
    SEARCH_EVENT = 12,
    GET_IMPORTANT_INFO = 13,
    ADD_COMMENT = 14,
    DELETE_COMMENT = 15,
    GET_COMMENTS = 16,
    ADD_GOOD = 17,
    CHANGE_SETTINGS = 18,
    CHANGE_PW = 19,
    ADD_PCOMMENT = 20,
    GET_PCOMMENTS = 21,
    DELETE_PCOMMENT = 22,
    GET_PHOTO_LIST = 23,
    GET_EVENT_PARTICIPANTS = 24,
    GET_AVATAR_UPDATETIME = 25,
    GET_VIDEO_LIST = 26,
    ADD_VCOMMENT = 27,
    GET_VCOMMENTS = 28,
    DELETE_VCOMMENT = 29,
    GET_EVENT_RECOMMEND = 30,
    GET_VERSION_INFO = 31,
    UPDATE_LOCATION =32,
    GET_NEARBY_FRIENDS = 33,
    KANKAN = 34,
    UPLOADPHOTO = 35,
    GET_FILE_URL = 36,
    VIDEOSERVER = 37,
    KICK_OUT = 38,
    QUIT_EVENT = 39,
    UPDATE_AVATAR = 40,
    COMPLAIN = 41,
    GET_GOOD_PHOTOS = 42,
    GET_WELCOME_PAGE = 43,
    GET_POSTER = 44,
    ALIAS_OPERATION = 45,
    SET_EVENT_BANNER = 46,
};

enum CloudOperation_Code
{
    DOWNLOAD = 1,
    UPLOAD = 2,
    DELETE = 3,
};


enum Return_Code
{
    NORMAL_REPLY =100,
    USER_NOT_FOUND = 101,
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
    SHARE_NOT_EXIST = 117,
    NOT_IN_EVENT = 118,
    QUIT_EVENT_SUC = 119,
    USER_NAME_EXIST = 120,
    USER_ALREADY_ONLINE = 121,
    USER_LOGOUT_SUC = 122,
    
    NEED_CONFIRM=198,
    INCOME_CONFIRM=199,
    
    //推送消息相关Return_Code
    ADD_FRIEND_NOTIFICATION=999,  //收到好友请求
    ADD_FRIEND_RESULT=998,      //收到好友请求结果，对方同意或拒绝
    NEW_EVENT_NOTIFICATION=997, //发起活动的邀请
    EVENT_INVITE_RESPONSE=996,  //活动邀请的结果，对方同意或拒绝
    REQUEST_EVENT=995,          //主动请求加入活动
    REQUEST_EVENT_RESPONSE=994, //主动请求加入活动的结果
    NEW_COMMENT_NOTIFICATION=993, //有评论更新
    NEW_PHOTO_NOTIFICATION=992,     //有照片更新
    NEW_VIDEO_NOTIFICATION=991,
    NEW_SHARE_NOTIFICATION=990,
    NEW_LIKE_NOTIFICATION=989,
    NEW_COMMENT_REPLY=988,
};

#endif
