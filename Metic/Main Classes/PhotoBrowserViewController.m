//
//  PhotoBrowserViewController.m
//  WeShare
//
//  Created by 俊健 on 16/2/21.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoDetailViewController.h"
#import "PhotoDisplayViewController.h"
#import "PictureWall2.h"
#import "PhotoBrowserCell.h"
#import "CommonUtils.h"
#import "SwipeView.h"
#import "SVProgressHUD.h"

@interface PhotoBrowserViewController () <SwipeViewDataSource, SwipeViewDelegate, UMSocialUIDelegate>

@property (nonatomic, strong) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) PhotoDetailViewController *selectedPhotoDetailVC;

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *eventInfo;
@property (nonatomic) NSInteger showIndex;

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSNumber *eventLauncherId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic) BOOL canManage;

@end

@implementation PhotoBrowserViewController

- (instancetype)initWithEventInfo:(NSDictionary *)eventInfo PhotoDists:(NSArray *)photos showPhotoIndex:(NSInteger)index {
    self = [self init];
    if (self) {
        self.photos = photos;
        self.eventInfo = eventInfo;
        self.showIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.swipeView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showPhotoInIndex:self.showIndex];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self swipeViewDidEndDecelerating:self.swipeView];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.swipeView.delegate = nil;
    self.swipeView.dataSource = nil;
}

#pragma mark - Navi
- (void)showPhotos {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    PhotoDisplayViewController* photoDisplay = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDisplayViewController"];
    
    photoDisplay.photo_list = [NSMutableArray arrayWithArray:self.photos];
    photoDisplay.photoIndex = self.swipeView.currentItemIndex;
    photoDisplay.eventId = self.eventId;
    photoDisplay.eventLauncherId = self.eventLauncherId;
    photoDisplay.eventName = self.eventName;
//    photoDisplay.controller = self;
    photoDisplay.canManage = [[self.eventInfo valueForKey:@"isIn"]boolValue];
    
    [self.navigationController pushViewController:photoDisplay animated:YES];
}

#pragma mark - Get & Set
- (NSNumber *)eventId {
    return [self.eventInfo valueForKey:@"event_id"];
}

- (NSNumber *)eventName {
    return [self.eventInfo valueForKey:@"subject"];
}

- (NSNumber *)eventLauncherId {
    return [self.eventInfo valueForKey:@"launcher_id"];
}

- (BOOL)canManage {
    return [[self.eventInfo valueForKey:@"isIn"]boolValue];
}

- (void)showPhotoInIndex:(NSInteger)index {
    if (index >= 0 && index < self.photos.count) {
        self.showIndex = index;
        [self.swipeView scrollToItemAtIndex:self.showIndex duration:0];
    }
    [self swipeViewDidEndDecelerating:self.swipeView];
}

#pragma mark - UI setup
- (void)setupUI {
    self.title = @"图片详情";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    self.swipeView.pagingEnabled = YES;
    [self.swipeView reloadData];
}

- (void)setTableViewScrollEnabled:(BOOL)scrollEnabled {
    self.swipeView.scrollEnabled = scrollEnabled;
}

- (PhotoDetailViewController *)photoDetailVCwithIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.photos.count) {
        return nil;
    }
    
    if (self.showIndex > 0 && self.selectedPhotoDetailVC) {
        return self.selectedPhotoDetailVC;
    } else if (self.showIndex > 0 && !self.selectedPhotoDetailVC) {
        index = self.showIndex;
    }
    
    NSMutableDictionary *photoInfo = self.photos[index];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    PhotoDetailViewController *detailViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    detailViewController.photoId = photoInfo[@"photo_id"];
    detailViewController.eventId = self.eventInfo[@"event_id"];
    detailViewController.eventLauncherId = self.eventInfo[@"launcher_id"];
    detailViewController.photoInfo = photoInfo;
    detailViewController.eventName = self.eventInfo[@"subject"];
    detailViewController.canManage = [[self.eventInfo valueForKey:@"isIn"]boolValue];
    
    if (self.showIndex > 0 && !self.selectedPhotoDetailVC) {
        self.selectedPhotoDetailVC = detailViewController;
    }
    return detailViewController;
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.photos.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    PhotoDetailViewController *detailViewController = [self photoDetailVCwithIndex:index];
    if (self.showIndex == index) {
        self.showIndex = -1;
        self.selectedPhotoDetailVC = nil;
    }
    [self addChildViewController:detailViewController];
    CGRect frame = self.swipeView.bounds;
    detailViewController.view.frame = frame;
    [detailViewController didMoveToParentViewController:self];
    
    return detailViewController.view;
}

#pragma mark SwipeView Delegate
- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView {
    
    for (PhotoDetailViewController *detailVC in self.childViewControllers) {
        if (detailVC && [detailVC respondsToSelector:@selector(textInputView)]) {
            [detailVC.textInputView dismissKeyboard];
        }
    }
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    
    PhotoDetailViewController *visibleVC;
    for (PhotoDetailViewController *detailVC in self.childViewControllers) {
        if (![swipeView.visibleItemViews containsObject:detailVC.view]) {
            [detailVC.view removeFromSuperview];
            [detailVC removeFromParentViewController];
        } else {
            visibleVC = detailVC;
        }
    }
    if (visibleVC) {
        [visibleVC tabbarButtonOption];
    }
}

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        MTLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [SVProgressHUD showSuccessWithStatus:@"分享成功" duration:2.f];
    }
}

@end
