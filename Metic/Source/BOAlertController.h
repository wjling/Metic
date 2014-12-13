//  Created by 孙俊 on 14-9-25.
//  Copyright (c) 2014年 yipinapp.ibrand. All rights reserved.
//

typedef enum {
    RIButtonItemType_Cancel         = 1,
    RIButtonItemType_Destructive       ,
    RIButtonItemType_Other
}RIButtonItemType;

typedef enum {
    BOAlertControllerType_AlertView    = 1,
    BOAlertControllerType_ActionSheet
}BOAlertControllerType;

#define isIOS8  ([[[UIDevice currentDevice]systemVersion]floatValue]>=8)

#import <Foundation/Foundation.h>
#import "RIButtonItem.h"

@interface BOAlertController : NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)inViewController;
- (void)addButton:(RIButtonItem *)button type:(RIButtonItemType)itemType;

//Show ActionSheet in all versions
- (void)showInView:(UIView *)view;

//Show AlertView in all versions
- (void)show;

@end