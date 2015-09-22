//
//  ProfileViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController
{
//    SRWebSocket* mySocket;
}
@synthesize mySocket;
@synthesize msg;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self reconnect];
    UISwipeGestureRecognizer* gesture_swipe_right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeRight:)];
    gesture_swipe_right.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer* gesture_swipe_left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeft:)];
    gesture_swipe_left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:gesture_swipe_right];
    [self.view addGestureRecognizer:gesture_swipe_left];
}

- (void) handleSwipeRight:(UIGestureRecognizer*)gesture
{
    MTLOG(@"handle swipe right");
}

- (void) handleSwipeLeft:(UIGestureRecognizer*)gesture
{
    MTLOG(@"handle swipe left");
}


#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}



/////////////////////////testing socket/////////////

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reconnect];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    mySocket.delegate = nil;
    [mySocket close];
    mySocket = nil;
}

- (IBAction)testingSocket:(id)sender {
    NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:10],@"uid",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [mySocket send:jsonData];
//    [self reconnect];
}


- (IBAction)heartbeat:(id)sender {
    [mySocket send:@""];
    MTLOG(@"心一跳");
}
- (IBAction)confirmPush:(id)sender {
    NSDictionary* json = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:10],@"uid",@"feedback",@"cmd",[NSNumber numberWithInt:146],@"seq",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [mySocket send:jsonData];
}

- (void)reconnect
{
    mySocket.delegate = nil;
    [mySocket close];
    
    NSString* str = @"ws://222.200.182.183:10088/";
//    NSString* str = @"ws://localhost:9000/chat";
    NSURL* url = [[NSURL alloc]initWithString:str];
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
    mySocket = [[SRWebSocket alloc]initWithURLRequest:request];
    mySocket.delegate = self;
    MTLOG(@"Connecting...");
    [mySocket open];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    MTLOG(@"Get message: %@",message);
    self.msg.text = [NSString stringWithFormat:@"Get message: %@",message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    MTLOG(@"Websocket Connected");
    self.msg.text = @"connected";
    
//    [mySocket send:@""];
//    MTLOG(@"send data");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    MTLOG(@":( Websocket Failed With Error %@", error);
    self.msg.text = [NSString stringWithFormat:@":( Websocket Failed With Error %@", error];
    mySocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    MTLOG(@"WebSocket closed, code: %d,reason: %@",code,reason);
    self.msg.text = @"closed";
    mySocket = nil;
    //    [self reconnect];
}

@end
