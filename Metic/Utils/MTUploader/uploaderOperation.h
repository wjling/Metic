//
//  uploaderOperation.h
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface uploaderOperation : NSOperation
@property float progress;
@property (nonatomic,strong) NSMutableDictionary* photoInfo;

- (id)initWithimgAsset:(ALAsset *)imgAsset eventId:(NSNumber*)eventId imageName:(NSString*)imageName;
- (id)initWithimgAssetStr:(NSString *)imgAssetStr eventId:(NSNumber*)eventId imageName:(NSString*)imageName;
@end
