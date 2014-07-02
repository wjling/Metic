//
//  PhotoDisplayViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDisplayViewController.h"


@interface PhotoDisplayViewController ()

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.photos = [[NSMutableDictionary alloc]init];
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.delegate = self;
    if (self.photoscache) {
        [self.scrollView setContentSize:CGSizeMake(320*self.photoPath_list.count, self.view.bounds.size.height)];
        [self.scrollView setContentOffset:CGPointMake(320*self.photoIndex, 0)];
    }
    [self.view addSubview:self.scrollView];
    [self displaythreePhoto:self.photoIndex];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displaythreePhoto:(int)photoIndex
{
    [self displaynthPhoto:photoIndex];
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
    UIImageView *photo = [self.photos valueForKey:[NSString stringWithFormat:@"%d",photoIndex]];
    if (photo) {
        return;
    }
    photo = [[UIImageView alloc]init];
    UIImage *img = [self.photoscache valueForKey:self.photoPath_list[photoIndex]];
    
    [self.photos setValue:photo forKey:[NSString stringWithFormat:@"%d",photoIndex]];
    
    if (img) {
        float photoHeight;
        if (img.size.width) {
            photoHeight = img.size.height*316/img.size.width;
        }else
        {
            NSLog(@"adsfad");
        }
        
        photo.image = img;
        [photo setFrame:CGRectMake(320*photoIndex+2,(self.view.bounds.size.height-photoHeight)/2,316, photoHeight)];
        [self.scrollView addSubview:photo];
    }else{
        [photo setFrame:CGRectMake(320*photoIndex,0,316, 0)];
        [self.scrollView addSubview:photo];
        PhotoGetter *photoGetter = [[PhotoGetter alloc]initWithData:photo path:self.photoPath_list[photoIndex] type:3 cache:self.photoscache];
        [photoGetter setTypeOption3:nil];
        photoGetter.mDelegate = self;
        [photoGetter getPhoto];
        
    }
    
    
}


#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    float photoHeight;
    if (image.size.width) {
        photoHeight = image.size.height*316/image.size.width;
    }else
    {
        NSLog(@"adsfad");
    }
    photoHeight = image.size.height*316/image.size.width;
    imageView.image = image;
    [imageView setFrame:CGRectMake(imageView.frame.origin.x+2,(self.view.bounds.size.height-photoHeight)/2,316, photoHeight)];
    [self.scrollView addSubview:imageView];
}


#pragma mark - UiScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%f",self.scrollView.contentOffset.x);
    int position = self.scrollView.contentOffset.x/310;
    [self displaythreePhoto:position];
}
@end
