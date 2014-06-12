//
//  AppDelegate.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize mySocket;

//@synthesize user;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
	MenuViewController *rightMenu = (MenuViewController*)[mainStoryboard
                                                          instantiateViewControllerWithIdentifier: @"MenuViewController"];
	rightMenu.view.backgroundColor = [UIColor yellowColor];
	rightMenu.cellIdentifier = @"rightMenuCell";
	
	MenuViewController *leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
	leftMenu.view.backgroundColor = [UIColor lightGrayColor];
	leftMenu.cellIdentifier = @"leftMenuCell";
	
	[SlideNavigationController sharedInstance].righMenu = rightMenu;
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [[MTUser alloc]init];
    return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - SRWebSocketDelegate
- (void)connect
{
    mySocket.delegate = nil;
    [mySocket close];
    
    NSString* str = @"ws://222.200.182.183:10088/";
    //    NSString* str = @"ws://localhost:9000/chat";
    NSURL* url = [[NSURL alloc]initWithString:str];
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
    mySocket = [[SRWebSocket alloc]initWithURLRequest:request];
    mySocket.delegate = self;
    NSLog(@"Connecting...");
    [mySocket open];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Get message: %@",message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    mySocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed, code: %d,reason: %@",code,reason);
    mySocket = nil;
}



@end
