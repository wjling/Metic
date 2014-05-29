//
//  FriendInfoViewController.h
//  Metic
//
//  Created by ligang5 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MySqlite.h"

@interface FriendInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *testingButton;

- (IBAction)testingClicked:(id)sender;

@end
