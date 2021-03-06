//
//  SlideNavigationController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Slide-Menu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@interface UINavigationController (SlideNavigationController)<UIGestureRecognizerDelegate>

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

#import "SlideNavigationController.h"
#import "../Main Classes/LaunchEventViewController.h"

@interface SlideNavigationController()
{
    UIImageView* dian;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint draggingPoint;
@property (nonatomic, assign) CGPoint beginPoint;
@property (atomic, assign) BOOL shouldIgnorePushingViewControllers;

@end

@implementation SlideNavigationController
{
    SRWebSocket* mySocket;
}
@synthesize righMenu;
@synthesize leftMenu;
@synthesize tapRecognizer;
@synthesize panRecognizer;
@synthesize draggingPoint;
@synthesize leftbarButtonItem;
@synthesize rightBarButtonItem;
@synthesize enableSwipeGesture;

#define PAN_EDGE_THRESHOLD 20
#define MENU_OFFSET (kMainScreenWidth * 0.1875f)
#define MENU_SLIDE_ANIMATION_DURATION .3
#define MENU_QUICK_SLIDE_ANIMATION_DURATION .1
#define MENU_IMAGE @"slide_icon"

static SlideNavigationController *singletonInstance;

#pragma mark - Initialization -

+ (SlideNavigationController *)sharedInstance
{
	return singletonInstance;
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if (self = [super initWithRootViewController:rootViewController])
	{
		[self setup];
	}
	
	return self;
}

- (id)init
{
	if (self = [super init])
	{
		[self setup];
	}
	
	return self;
}

- (void)setup
{
	self.avoidSwitchingToSameClassViewController = YES;
	singletonInstance = self;
	self.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleUIApplicationWillChangeStatusBarFrameNotification:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
     if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
         [self.navigationBar setTintColor:[UIColor colorWithRed:86/255.0f green:202/255.0f  blue:171/255.0f alpha:1.0f]];
     } else [self.navigationBar setTintColor:[UIColor whiteColor]];
	self.navigationBar.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
	[self setEnableSwipeGesture:YES];
    self.shouldIgnorePushingViewControllers = NO;
    //    [self reconnect];
}

- (void)setEffection:(BOOL)isEffection {
    if (isEffection) {
        self.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.view.layer.shadowRadius = 5;
        self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
        self.view.layer.shadowOpacity = 1;
        self.view.layer.shouldRasterize = YES;
        self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    } else {
        self.view.layer.shadowColor = [UIColor clearColor].CGColor;
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

#pragma mark - Public Methods -

- (void)switchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion
{
	if (self.avoidSwitchingToSameClassViewController && [self.topViewController isKindOfClass:viewController.class])
	{
		[self closeMenuWithCompletion:completion];
		return;
	}
	
	__block CGRect rect = self.view.frame;
	
	if (YES || [self isMenuOpen])
	{
		[UIView animateWithDuration:MENU_SLIDE_ANIMATION_DURATION
							  delay:0
							options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
                             rect.origin.x = (rect.origin.x >= 0) ? rect.size.width : -1*rect.size.width;
                             self.view.frame = rect;
                         } completion:^(BOOL finished) {
                             
                             [super popToRootViewControllerAnimated:NO];
                             [super pushViewController:viewController animated:NO];
                             
                             [self closeMenuWithCompletion:^{
                                 if (completion)
                                     completion();
                             }];
                         }];
	}
	else
	{
		[super popToRootViewControllerAnimated:NO];
		[super pushViewController:viewController animated:YES];
		
		if (completion)
			completion();
	}
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	if ([self isMenuOpen])
	{
		[self closeMenuWithCompletion:^{
			[super popToRootViewControllerAnimated:animated];
		}];
	}
	else
	{
		return [super popToRootViewControllerAnimated:animated];
	}
	
	return nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.shouldIgnorePushingViewControllers)
    {
//        self.shouldIgnorePushingViewControllers = YES;
        if ([self isMenuOpen])
        {
            [self closeMenuWithCompletion:^{
                [super pushViewController:viewController animated:animated];
            }];
        }
        else
        {
            [super pushViewController:viewController animated:animated];
        }
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.shouldIgnorePushingViewControllers)
    {
//        self.shouldIgnorePushingViewControllers = YES;
        if ([self isMenuOpen])
        {
            [self closeMenuWithCompletion:^{
                [super popToViewController:viewController animated:animated];
            }];
        }
        else
        {
            return [super popToViewController:viewController animated:animated];
        }
        return nil;
    }
    return nil;
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (!self.shouldIgnorePushingViewControllers)
    {
//        self.shouldIgnorePushingViewControllers = YES;
        return [super popViewControllerAnimated:animated];
    }
    return nil;
}

- (void)showLeftBarButtonDian
{
//    if (self.leftbarButtonItem)
    {
        dian.hidden = NO;
        MTLOG(@"显示左上角的红点");
    }
    
}

- (void)hideLeftBarButtonDian
{
//    if (self.leftbarButtonItem)
    {
        dian.hidden = YES;
    }
    MTLOG(@"隐藏左上角的红点");
}

#pragma mark - Private Methods -

- (UIBarButtonItem *)barButtonItemForMenu:(Menu)menu
{
    if (!dian) {
        dian = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        dian.image = [UIImage imageNamed:@"slidebar_icon_redpoint"];
        dian.tag = 111;
        
        NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
        NSDictionary* userSettings = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSDictionary* unRead_dic = [userSettings objectForKey:@"hasUnreadNotification1"];
        NSInteger tab_0 = [[unRead_dic objectForKey:@"tab_0"] integerValue];
        NSInteger tab_1 = [[unRead_dic objectForKey:@"tab_1"] integerValue];
        NSInteger tab_2 = [[unRead_dic objectForKey:@"tab_2"] integerValue];
        
        if (tab_0 + tab_1 + tab_2 > 0) {
            dian.hidden = NO;
        } else {
            dian.hidden = YES;
        }
    }
    
	SEL selector = (menu == MenuLeft) ? @selector(leftMenuSelected:) : @selector(righttMenuSelected:);
	UIBarButtonItem *customButton = (menu == MenuLeft) ? self.leftbarButtonItem : self.rightBarButtonItem;
	if (customButton)
	{
		customButton.action = selector;
		customButton.target = self;
		return customButton;
	}
	else
	{
		UIImage *image = [UIImage imageNamed:MENU_IMAGE];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setFrame:CGRectMake(0, 0, 71, 33)];
            [leftButton setImage:image forState:UIControlStateNormal];
            [leftButton setTitle:@"        " forState:UIControlStateNormal];
            [leftButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
            [leftButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            [dian removeFromSuperview];
            [leftButton addSubview:dian];
            UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
            return leftButtonItem;
        }else
        {
            UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setFrame:CGRectMake(0, 0, 30, 30)];
            [leftButton setImage:image forState:UIControlStateNormal];
            [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [leftButton setContentMode:UIViewContentModeScaleAspectFit];
            [leftButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            [dian removeFromSuperview];
            [leftButton addSubview:dian];
            UIBarButtonItem* leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//            [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:selector];
            return leftButtonItem;
        }
	}
    
}

- (BOOL)isMenuOpen
{
	return (self.view.frame.origin.x == 0) ? NO : YES;
}


- (BOOL)shouldDisplayMenu:(Menu)menu forViewController:(UIViewController *)vc
{
	if (menu == MenuRight)
	{
		if ([vc respondsToSelector:@selector(slideNavigationControllerShouldDisplayRightMenu)] &&
			[(UIViewController<SlideNavigationControllerDelegate> *)vc slideNavigationControllerShouldDisplayRightMenu])
		{
			return YES;
		}
	}
	if (menu == MenuLeft)
	{
		if ([vc respondsToSelector:@selector(slideNavigationControllerShouldDisplayLeftMenu)] &&
			[(UIViewController<SlideNavigationControllerDelegate> *)vc slideNavigationControllerShouldDisplayLeftMenu])
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)openMenu:(Menu)menu withDuration:(float)duration andCompletion:(void (^)())completion
{
	[self.topViewController.view addGestureRecognizer:self.tapRecognizer];
	
	if (menu == MenuLeft)
	{
		[self.righMenu.view removeFromSuperview];
		[self.view.window insertSubview:self.leftMenu.view atIndex:0];
	}
	else
	{
		[self.leftMenu.view removeFromSuperview];
		[self.view.window insertSubview:self.righMenu.view atIndex:0];
	}
	
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect = self.view.frame;
						 rect.origin.x = (menu == MenuLeft) ? (rect.size.width - MENU_OFFSET) : ((rect.size.width - MENU_OFFSET )* -1);
						 self.view.frame = rect;
					 }
					 completion:^(BOOL finished) {
						 if (completion)
							 completion();
					 }];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                            [self.vc.view viewWithTag:101 ].alpha = 260.0/400.0;
                            self.navigationBar.alpha = 1 - 260/400.0;
                        }completion:^(BOOL finished){
                            
                        }];
}

- (void)openMenu:(Menu)menu withCompletion:(void (^)())completion
{
	[self openMenu:menu withDuration:MENU_SLIDE_ANIMATION_DURATION andCompletion:completion];
}

- (void)closeMenuWithDuration:(float)duration andCompletion:(void (^)())completion
{
	[self.topViewController.view removeGestureRecognizer:self.tapRecognizer];
	
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect = self.view.frame;
						 rect.origin.x = 0;
						 self.view.frame = rect;
					 }
					 completion:^(BOOL finished) {
						 if (completion)
							 completion();
					 }];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                            [self.vc.view viewWithTag:101 ].alpha = 0.0;
                            self.navigationBar.alpha = 1;
                        }completion:^(BOOL finished){
                            
                        }];
    
}

- (void)closeMenuWithCompletion:(void (^)())completion
{
	[self closeMenuWithDuration:MENU_SLIDE_ANIMATION_DURATION andCompletion:completion];
}

#pragma mark - UINavigationControllerDelegate Methods -

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
    self.vc = viewController;
	if ([self shouldDisplayMenu:MenuLeft forViewController:viewController])
		viewController.navigationItem.leftBarButtonItem = [self barButtonItemForMenu:MenuLeft];
	
	if ([self shouldDisplayMenu:MenuRight forViewController:viewController])
		viewController.navigationItem.rightBarButtonItem = [self barButtonItemForMenu:MenuRight];
}

#pragma mark - IBActions -

- (void)leftMenuSelected:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	if ([self isMenuOpen])
		[self closeMenuWithCompletion:nil];
	else
		[self openMenu:MenuLeft withCompletion:nil];
    
}

- (void)righttMenuSelected:(id)sender
{
	if ([self isMenuOpen])
		[self closeMenuWithCompletion:nil];
	else
		[self openMenu:MenuRight withCompletion:nil];
}

#pragma mark - Gesture Recognizing -

- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
	[self closeMenuWithCompletion:nil];
}

- (void)panDetected:(UIPanGestureRecognizer *)aPanRecognizer
{
	static NSInteger velocityForFollowingDirection = 1000;
	CGPoint translation = [aPanRecognizer translationInView:aPanRecognizer.view];
    CGPoint velocity = [aPanRecognizer velocityInView:aPanRecognizer.view];
	
    if (aPanRecognizer.state == UIGestureRecognizerStateBegan)
	{
        CGPoint currentPoint = [aPanRecognizer locationInView:self.view];
		self.draggingPoint = translation;
        self.beginPoint = currentPoint;
    }
	else if (aPanRecognizer.state == UIGestureRecognizerStateChanged)
	{
        NSInteger movement = translation.x - self.draggingPoint.x;
        CGRect rect = self.view.frame;
        rect.origin.x += movement;
        float distance = self.view.frame.origin.x;
        if (rect.origin.x >= self.minXForDragging && rect.origin.x <= self.maxXForDragging)
            self.view.frame = rect;
        if ([self.vc respondsToSelector:@selector(slideNavigationControllerShouldDisplayLeftMenu)] &&
			[(UIViewController<SlideNavigationControllerDelegate> *)self.vc slideNavigationControllerShouldDisplayLeftMenu])
		{
			[(UIViewController<SlideNavigationControllerDelegate> *)self.vc sendDistance:distance];
		}
        
        
        self.draggingPoint = translation;
        
        if (rect.origin.x > 0)
        {
            [self.righMenu.view removeFromSuperview];
            [self.view.window insertSubview:self.leftMenu.view atIndex:0];
        }
        else
        {
            [self.leftMenu.view removeFromSuperview];
            [self.view.window insertSubview:self.righMenu.view atIndex:0];
        }
        
	}
	else if (aPanRecognizer.state == UIGestureRecognizerStateEnded)
	{
        //if ((self.beginPoint.x <= PAN_EDGE_THRESHOLD ) || (self.beginPoint.x >= (self.view.bounds.size.width - PAN_EDGE_THRESHOLD  -50))) {
        NSInteger currentX = self.view.frame.origin.x;
        NSInteger currentXOffset = (currentX > 0) ? currentX : currentX * -1;
        NSInteger positiveVelocity = (velocity.x > 0) ? velocity.x : velocity.x * -1;
        
        // If the speed is high enough follow direction
        if (positiveVelocity >= velocityForFollowingDirection)
        {
            // Moving Right
            if (velocity.x > 0)
            {
                if (currentX > 0)
                {
                    [self openMenu:(velocity.x > 0) ? MenuLeft : MenuRight withCompletion:nil];
                }
                else
                {
                    [self closeMenuWithDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
                }
            }
            // Moving Left
            else
            {
                if (currentX > 0)
                {
                    [self closeMenuWithCompletion:nil];
                }
                else
                {
                    Menu menu = (velocity.x > 0) ? MenuLeft : MenuRight;
                    
                    if ([self shouldDisplayMenu:menu forViewController:self.visibleViewController])
                        [self openMenu:(velocity.x > 0) ? MenuLeft : MenuRight withDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
                }
            }
        }
        else
        {
            if (currentXOffset < self.view.frame.size.width/2)
                [self closeMenuWithCompletion:nil];
            else
                [self openMenu:(currentX > 0) ? MenuLeft : MenuRight withCompletion:nil];
        }
    }
    // }
}

- (NSInteger)minXForDragging
{
	if ([self shouldDisplayMenu:MenuRight forViewController:self.topViewController])
	{
		return (self.view.frame.size.width - MENU_OFFSET)  * -1;
	}
	
	return 0;
}

- (NSInteger)maxXForDragging
{
	if ([self shouldDisplayMenu:MenuLeft forViewController:self.topViewController])
	{
		return self.view.frame.size.width - MENU_OFFSET;
	}
	
	return 0;
}

#pragma mark - Setter & Getter -

- (UITapGestureRecognizer *)tapRecognizer
{
	if (!tapRecognizer)
	{
		tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
	}
	
	return tapRecognizer;
}

- (UIPanGestureRecognizer *)panRecognizer
{
	if (!panRecognizer)
	{
		panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        panRecognizer.delegate = self;
	}
	
	return panRecognizer;
}

- (void)setEnableSwipeGesture:(BOOL)markEnableSwipeGesture
{
	enableSwipeGesture = markEnableSwipeGesture;
	
	if (enableSwipeGesture)
	{
		[self.view addGestureRecognizer:self.panRecognizer];
	}
	else
	{
		[self.view removeGestureRecognizer:self.panRecognizer];
	}
}

- (void)openMenuAndSwitchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion
{
    [self openMenu:MenuLeft withCompletion:^{
        [self switchToViewController:viewController withCompletion:completion];
    }];
}

#pragma mark - Private API

// This is confirmed to be App Store safe.
// If you feel uncomfortable to use Private API, you could also use the delegate method navigationController:didShowViewController:animated:.
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.shouldIgnorePushingViewControllers = NO;
}

#pragma mark UIApplicationWillChangeStatusBarFrameNotification
// 如有必要，需监听系统状态栏变更通知：UIApplicationWillChangeStatusBarFrameNotification
- (void)handleUIApplicationWillChangeStatusBarFrameNotification:(NSNotification*)notification
{
    // 根据系统状态栏高判断热点栏的变动
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect wframe = self.view.window.frame;
        CGRect frame = self.view.frame;
        if (CGRectGetMaxY(frame) > CGRectGetHeight(wframe)) {
            frame.size.height = CGRectGetHeight(wframe) - CGRectGetMinY(frame);
            [self.view setFrame:frame];
            
        }
    });
}

#pragma mark - UIGestureRecognizer Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    CGPoint currentPoint = [touch locationInView:self.view];
    if (currentPoint.x < MENU_OFFSET) {
        return YES;
    }
    return NO;
}
@end


