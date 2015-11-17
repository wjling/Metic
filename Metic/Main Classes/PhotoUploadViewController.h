//
//  PhotoUploadViewController.h
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "PECropViewController.h"
#import "UzysAssetsPickerController.h"


@interface PhotoUploadViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,UzysAssetsPickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIViewController* photoWallController;
@property (strong, nonatomic) NSNumber* eventId;
- (IBAction)upload:(id)sender;

@end
