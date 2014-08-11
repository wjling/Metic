//
//  AddFriendComfirmViewController.h
//  Metic
//
//  Created by mac on 14-8-11.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtils.h"
#import "HttpSender.h"
#import "MTUser.h"

@interface AddFriendComfirmViewController : UIViewController<HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UITextField *comfirm_textField;
@property (strong, nonatomic) IBOutlet UIButton *ok_button;
@property (strong, nonatomic) IBOutlet UIButton *left_barbutton;
@property (strong, nonatomic) NSNumber* fid;

- (IBAction)leftBarBtnClicked:(id)sender;
- (IBAction)okBtnClicked:(id)sender;

@end
