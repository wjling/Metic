//
//  PhotoBrowserViewController.m
//  WeShare
//
//  Created by 俊健 on 16/2/21.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoDetailViewController.h"
#import "PictureWall2.h"
#import "PhotoBrowserCell.h"
#import "CommonUtils.h"

@interface PhotoBrowserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *eventInfo;
@property (nonatomic) NSInteger showIndex;

@property (nonatomic, strong) PhotoDetailViewController *seletedDetailViewController;

@end

@implementation PhotoBrowserViewController
@synthesize tableView;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI setup
- (void)setupUI {
    self.title = @"图片详情";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    
    CGRect tableViewRect = CGRectMake(0.0, 0.0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    tableView.center = self.view.center;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    
    //tableview逆时针旋转90度。
    tableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    tableView.showsVerticalScrollIndicator = NO;
    tableView.scrollEnabled = YES;
    tableView.pagingEnabled = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view = tableView;
    
    self.seletedDetailViewController = [self photoDetailVCwithIndex:self.showIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.showIndex inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        
    });
}

- (void)setTableViewScrollEnabled:(BOOL)scrollEnabled {
    tableView.scrollEnabled = scrollEnabled;
}

- (PhotoDetailViewController *)photoDetailVCwithIndex:(NSInteger)index {
    
    if (self.seletedDetailViewController) {
        return self.seletedDetailViewController;
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
    
    return detailViewController;
}

#pragma mark - UITableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowserCell *cell = [[PhotoBrowserCell alloc] init];
    cell.transform = CGAffineTransformMakeRotation(M_PI / 2);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger index = indexPath.row;
    
    
    PhotoDetailViewController *detailViewController;
    
    if (self.seletedDetailViewController) {
        detailViewController = self.seletedDetailViewController;
        if (index == self.showIndex) {
            self.seletedDetailViewController = nil;
        }
    } else {
        detailViewController = [self photoDetailVCwithIndex:index];
    }
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame));
    detailViewController.view.frame = frame;
    
    cell.detailViewController = detailViewController;
    
    [self addChildViewController:detailViewController];
    [cell addSubview:detailViewController.view];
    [detailViewController didMoveToParentViewController:self];
    
    return cell;
}

#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowserCell *browserCell = (PhotoBrowserCell *)cell;
    [browserCell.detailViewController.view removeFromSuperview];
    [browserCell.detailViewController removeFromParentViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(self.view.bounds);
    return height;
}

#pragma mark UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray *visibleCells = tableView.visibleCells;
    for (PhotoBrowserCell *browserCell in visibleCells) {
        PhotoDetailViewController *detailVC = browserCell.detailViewController;
        if (detailVC.inputTextView.isFirstResponder) {
            [detailVC.inputTextView resignFirstResponder];
        }
    }
}

@end
