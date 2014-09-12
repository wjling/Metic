//
//  PhotoUploadViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Utils/PhotoGetter.h"
#import "PECropViewController.h"


@interface PhotoUploadViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,HttpSenderDelegate,PhotoGetterDelegate,PECropViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIViewController* photoWallController;
@property (strong, nonatomic) NSNumber* eventId;
- (IBAction)upload:(id)sender;

@end
