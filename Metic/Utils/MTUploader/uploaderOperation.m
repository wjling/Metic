//
//  uploaderOperation.m
//  WeShare
//
//  Created by ligang6 on 15-3-7.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "uploaderOperation.h"

@interface uploaderOperation (){
    BOOL _executing;
    BOOL _finished;
}
@property (nonatomic,strong) NSString* imageName;
@property (nonatomic,strong) NSString* eventId;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end


@implementation uploaderOperation


- (id)initWithImageName:(NSString *)imageName eventId:(NSNumber*)eventId{
    if ((self = [super init])) {
        _executing = NO;
        _finished = NO;
        _imageName = imageName;
        _eventId = eventId;
    }
    return self;
}

- (void)start
{
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
//            [self reset];
            return;
        }
    }
    
    NSLog(@"开始上传任务： %@  %@",_eventId,_imageName);
    
    
    
    
    
}









@end
