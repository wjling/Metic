//
//  PhotoDisplayViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDisplayViewController.h"
#import "PhotoDetailViewController.h"
#import "../Source/MRZoomScrollView.h"
#import "../Utils/PhotoGetter.h"
#import "../Utils/CommonUtils.h"


@interface PhotoDisplayViewController ()
@property BOOL isZan;
@property int goodindex;
@property int lastViewIndex;
@property int movedown;
@property (nonatomic,strong)SDWebImageManager *manager;
@end

@implementation PhotoDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //[self.InfoView setHidden:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.movedown = -44;
    }else self.movedown = -64;

    self.lastViewIndex = self.photoIndex;
    self.photos = [[NSMutableDictionary alloc]init];
    CGRect frame = self.view.bounds;
    frame.origin.y = -64;
    self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(320*self.photoPath_list.count, self.view.bounds.size.height)];
    [self.scrollView setContentOffset:CGPointMake(320*self.photoIndex, 0)];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];
    _manager = [SDWebImageManager sharedManager];
    [self.InfoView setHidden:NO];
    [self.view bringSubviewToFront:self.InfoView];
    //单击手势
    UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleRecognizer.numberOfTapsRequired=1;
    //双击手势
    UITapGestureRecognizer * doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleRecognizer.numberOfTapsRequired=2;
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    [self.scrollView addGestureRecognizer:singleRecognizer];
    [self.scrollView addGestureRecognizer:doubleRecognizer];
    
    [self displaythreePhoto:self.photoIndex];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    self.commentImg.image = [UIImage imageNamed:@"评论icon"];
    [self refreshGood];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//

-(void)refreshGood
{
    int index = self.scrollView.contentOffset.x/320;
    NSDictionary* dict = self.photo_list[index];
    self.zan_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"good"]];
    BOOL iszan = [[self.photo_list[index] valueForKey:@"isZan"]boolValue];
    UIImage* zanImage = !iszan? [UIImage imageNamed:@"点赞icon"]:[UIImage imageNamed:@"实心点赞图"];
    self.goodImg.image = zanImage;
}
-(void)loadPictureDescription
{
    int index = self.scrollView.contentOffset.x/320;
    
    NSDictionary* dict = self.photo_list[index];
    self.zan_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"good"]];
    BOOL iszan = [[self.photo_list[index] valueForKey:@"isZan"]boolValue];
    UIImage* zanImage = !iszan? [UIImage imageNamed:@"点赞icon"]:[UIImage imageNamed:@"实心点赞图"];
    self.commentImg.image = [UIImage imageNamed:@"评论icon"];
    self.goodImg.image = zanImage;
    self.comment_num.text = [NSString stringWithFormat:@"%@",[dict valueForKey:@"comment_num"]];
    self.pictureDescription.text = [dict valueForKey:@"specification"];
    self.pictureAuthor.text = [dict valueForKey:@"author"];
    self.publishTime.text = [[dict valueForKey:@"time"] substringToIndex:10];
    self.photoId = [dict valueForKey:@"photo_id"];
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[dict valueForKey:@"author_id"]];
    [getter getPhoto];
    
    
    
}





-(void)handleSingleTap
{
    if(self.navigationController.navigationBarHidden){
        [self.navigationController setNavigationBarHidden:NO];
        [self.scrollView setFrame:CGRectMake(0, self.movedown, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.InfoView setHidden:NO];
        [self.view bringSubviewToFront:self.InfoView];
    }else{
        [self.navigationController setNavigationBarHidden:YES];
        [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.InfoView setHidden:YES];

    }
}

-(void)handleDoubleTap
{
}


-(void)displaythreePhoto:(int)photoIndex
{
    [self displaynthPhoto:photoIndex];
    [self loadPictureDescription];
    photoIndex++;
    if (photoIndex>=0 && photoIndex<self.photoPath_list.count) {
        [self displaynthPhoto:photoIndex];
    }
    photoIndex-=2;
    if (photoIndex>=0 && photoIndex<self.photoPath_list.count) {
        [self displaynthPhoto:photoIndex];
    }
}

-(void)displaynthPhoto:(int)photoIndex
{
    MRZoomScrollView *photoScrollView = [self.photos valueForKey:[NSString stringWithFormat:@"%d",photoIndex]];
    if (photoScrollView) {
        return;
    }
    MRZoomScrollView* zoomScrollView = [[MRZoomScrollView alloc]init];
    [zoomScrollView setFrame:CGRectMake(320*photoIndex+2,0,316, self.scrollView.frame.size.height)];

    [self.photos setValue:zoomScrollView forKey:[NSString stringWithFormat:@"%d",photoIndex]];
    NSString *url = _photoPath_list[photoIndex];
    [zoomScrollView.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]];
    if (zoomScrollView.imageView.image) {
        [zoomScrollView fitImageView];
    }
    
    [self.scrollView addSubview:zoomScrollView];
    
    
}



#pragma mark - UiScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int position = self.scrollView.contentOffset.x/320;
    if (self.lastViewIndex != position) {
        MRZoomScrollView *photoScrollView = [self.photos valueForKey:[NSString stringWithFormat:@"%d",self.lastViewIndex]];
        [photoScrollView zoomToNormal];
    }
    self.lastViewIndex = position;
    [self displaythreePhoto:position];
}


- (IBAction)appreciate:(id)sender {
    [(UIButton*)sender setEnabled:NO];
    self.goodindex = self.scrollView.contentOffset.x/320;
    BOOL iszan = [[self.photo_list[self.goodindex] valueForKey:@"isZan"]boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:[NSNumber numberWithInt:iszan? 2:3]  forKey:@"operation"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD];
}

- (IBAction)comment:(id)sender {
}

- (IBAction)comment_buttonDown:(id)sender {
    self.commentImg.image = [UIImage imageNamed:@"评论按下按钮icon"];
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:self.photo_list[self.goodindex]];
            BOOL iszan = [[dict valueForKey:@"isZan"]boolValue];
            int zan_number = [[dict valueForKey:@"good"]intValue];
            if (iszan) {
                zan_number --;
                self.goodImg.image = [UIImage imageNamed:@"点赞icon"];
                
            }else{
                zan_number ++;
                self.goodImg.image = [UIImage imageNamed:@"实心点赞图"];
            }
            self.zan_num.text = [NSString stringWithFormat:@"%d",zan_number];
            [dict setValue:[NSNumber numberWithBool:!iszan] forKey:@"isZan"];
            [dict setValue:[NSNumber numberWithInt:zan_number] forKey:@"good"];
            self.photo_list[self.goodindex] = dict;
            [self.goodButton setEnabled:YES];

        }
            break;
        default:
        {
            
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.sourceViewController isKindOfClass:[PhotoDisplayViewController class]]) {
        if ([segue.destinationViewController isKindOfClass:[PhotoDetailViewController class]]) {
            PhotoDetailViewController *nextViewController = segue.destinationViewController;
            int index = self.scrollView.contentOffset.x/320;
            
            nextViewController.photoId = [self.photo_list[index] valueForKey:@"photo_id"];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:self.photo_list[index]];
            self.photo_list[index] = dict;
            nextViewController.photo = [_manager.imageCache imageFromDiskCacheForKey:_photoPath_list[index]];
            nextViewController.photoInfo = dict;
            nextViewController.photoDisplayController = self;
        }
        
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView* touchedView = [touch view];
    if([touchedView isKindOfClass:[UIButton class]]) {
        
        return NO;
    }
    
    return YES;
}


@end
