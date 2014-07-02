//
//  ProfileViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "SRWebSocket.h"
#import "CommonUtils.h"

@interface ProfileViewController : UIViewController <SlideNavigationControllerDelegate,SRWebSocketDelegate>
@property(strong)SRWebSocket* mySocket;
@property (weak, nonatomic) IBOutlet UITextView *msg;
@property (strong, nonatomic) IBOutlet UIView *shadowView;

- (IBAction)testingSocket:(id)sender;

@end
