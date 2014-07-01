//
//  PhotoGetter.h
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudOperation.h"
#import "MTUser.h"


@protocol PhotoGetterDelegate

@optional
//当服务器返回数据的时候执行此方法
-(void)finishwithNotification:(UITableView*) tableView indexPath:(NSIndexPath*)indexPath;

@end
@interface PhotoGetter : NSObject <CloudOperationDelegate>
@property(nonatomic,strong)id <PhotoGetterDelegate> mDelegate;
@property(nonatomic,strong) UIImageView* imageView;
@property int type;
@property(nonatomic,strong) NSIndexPath* index;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSString* path;
@property(nonatomic,strong) NSString* filePath;
@property(nonatomic,strong) NSMutableDictionary *phothCache;
@property BOOL isCircle;
@property UIColor *borderColor;
@property CGFloat borderWidth;
@property (nonatomic,strong)MTUser *user;

- (instancetype)initWithData:(UIImageView*)animageView path:(NSString*)path type:(int)type cache:(NSMutableDictionary*)cache isCircle:(BOOL)isCircle borderColor:(UIColor*)borderColor borderWidth:(CGFloat) borderWidth;
-(void)getPhoto;
@end

