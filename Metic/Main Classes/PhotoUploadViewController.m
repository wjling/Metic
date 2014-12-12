//
//  PhotoUploadViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoUploadViewController.h"
#import "PictureWall2.h"
#import "../Category/UINavigationController+Vertical.h"
#import "../Utils/CommonUtils.h"
#import "THProgressView.h"
#import "MobClick.h"
#import "../Utils/Reachability.h"
#import "BOAlertController.h"

static const CGSize progressViewSize = { 200.0f, 30.0f };




@interface PhotoUploadViewController ()
@property (strong, nonatomic) UITextView* textInput;
@property (strong, nonatomic) UIView* textView;
@property (strong, nonatomic) UIView* imgView;
@property (strong, nonatomic) UIImageView* img;
@property (strong, nonatomic) UIImage* uploadImage;
@property (strong, nonatomic) UIButton* getPhoto;
@property (strong, nonatomic) UIButton* upLoad;
@property (strong, nonatomic) UITextField* preLabel;
@property (strong, nonatomic) UIView* waitingView;
@property (strong, nonatomic) THProgressView *progressView;

@end

@implementation PhotoUploadViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self drawLeftButton];
    self.scrollView.delegate = self;
    _textView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 290, 36)];
    [_textView setBackgroundColor:[UIColor whiteColor]];
    _textView.layer.cornerRadius = 5;
    _textView.layer.masksToBounds = YES;
    [self.scrollView addSubview:_textView];
    
    self.textInput = [[UITextView alloc]initWithFrame:CGRectMake(8, 0, 274, 36)];
    self.textInput.delegate = self;
    [self.textInput setBackgroundColor:[UIColor clearColor]];
    [self.textInput setFont:[UIFont systemFontOfSize:16]];
    [_textView addSubview:self.textInput];
    
    self.preLabel = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, 274, 36)];
    [self.preLabel setPlaceholder:@"这一刻的想法"];
    [self.preLabel setBackgroundColor:[UIColor clearColor]];
    [self.preLabel setEnabled:NO];
    self.preLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.preLabel setFont:[UIFont systemFontOfSize:18]];
    [_textView addSubview:self.preLabel];

    self.imgView =  [[UIView alloc] initWithFrame:CGRectMake(15, 66, 290, 78)];
    self.imgView.layer.cornerRadius = 5;
    self.imgView.layer.masksToBounds = YES;
    [self.imgView setBackgroundColor:[UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1]];
    [self.scrollView addSubview:self.imgView];
    
    self.getPhoto = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.getPhoto setFrame:CGRectMake(10, 9, 60 , 60)];
    [self.getPhoto setBackgroundImage:[UIImage imageNamed:@"加图片的加号"] forState:UIControlStateNormal];
    [self.getPhoto addTarget:self action:@selector(UesrImageClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.imgView addSubview:self.getPhoto];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MTdismissKeyboard)];
    [self.view addGestureRecognizer:tap];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"图片上传"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片上传"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"uploadFile" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    if(_uploadImage){
        [self alertConfirmQuit];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertConfirmQuit{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要放弃上传？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 120;
    [alert show];
}

- (void)drawLeftButton{
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 71, 33)];
    [leftButton setImage:[UIImage imageNamed:@"头部左上角图标-返回"] forState:UIControlStateNormal];
    [leftButton setTitle:@"        " forState:UIControlStateNormal];
    [leftButton.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [leftButton addTarget:self action:@selector(MTpopViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}


- (void)UesrImageClicked
{
    BOAlertController *actionSheet = [[BOAlertController alloc] initWithTitle:@"选择图像" message:nil viewController:self];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
    }];
    [actionSheet addButton:cancelItem type:RIButtonItemType_Destructive];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        RIButtonItem *takeItem = [RIButtonItem itemWithLabel:@"拍照" action:^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }];
        [actionSheet addButton:takeItem type:RIButtonItemType_Other];
    }
    
    
    RIButtonItem *seleteItem = [RIButtonItem itemWithLabel:@"从相册选择" action:^{
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        }else imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    [actionSheet addButton:seleteItem type:RIButtonItemType_Other];
    
    
    
    [actionSheet showInView:self.view];
}

-(void)MTdismissKeyboard
{
    [_textInput becomeFirstResponder];
    [_textInput resignFirstResponder];
}

- (void)openEditor:(UIImage*)image
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = image;

    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    controller.imageCropRect = CGRectMake(0, 0, width, height);
    [controller setToolbarHidden:YES];
//    CGFloat length = MIN(width, height);
//    controller.imageCropRect = CGRectMake((width - length) / 2,
//                                          (height - length) / 2,
//                                          length,
//                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navigationController.navigationBar setBarTintColor:[CommonUtils colorWithValue:0x56caab]];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [customLab setTextColor:[UIColor whiteColor]];
    [customLab setText:@"图片裁剪"];
    [customLab setTextAlignment:NSTextAlignmentCenter];
    customLab.font = [UIFont boldSystemFontOfSize:20];
    controller.navigationItem.titleView = customLab;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navigationController animated:NO completion:^{
    }];
    
}

- (IBAction)upload:(id)sender {
    if (!self.uploadImage) {
        [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"请选择图片" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0){
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"未连接网络" WithDelegate:nil WithCancelTitle:@"确定"];
        return;
    }
    
    [self showWaitingView];
    self.upLoad = sender;
//    [self.upLoad setEnabled:NO];
//    [self.getPhoto setEnabled:NO];
    PhotoGetter *getter = [[PhotoGetter alloc]initUploadMethod:self.uploadImage type:1];
    getter.mDelegate = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [getter uploadPhoto];
    });
    
}

-(void)showWaitingView
{
    if (!_waitingView) {
        [_textInput resignFirstResponder];
        CGRect frame = [UIScreen mainScreen].bounds;
        _waitingView = [[UIView alloc]initWithFrame:frame];
        [_waitingView setBackgroundColor:[UIColor blackColor]];
        [_waitingView setAlpha:0.7f];
        [self.view addSubview:_waitingView];
        
        _progressView = [[THProgressView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_waitingView.frame) - progressViewSize.width / 2.0f,
                                                                         CGRectGetMidY(_waitingView.frame) - progressViewSize.height / 2.0f,
                                                                         progressViewSize.width,
                                                                         progressViewSize.height)];
        _progressView.borderTintColor = [UIColor whiteColor];
        _progressView.progressTintColor = [UIColor whiteColor];
        [_progressView setProgress:0 animated:NO];
        [_waitingView addSubview:_progressView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyProgress:) name: @"uploadFile" object:nil];
        
        
        
        [[UIApplication sharedApplication].keyWindow addSubview:_waitingView];
    }
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [_waitingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name: @"uploadFile" object:nil];
        _waitingView = nil;
    }
}

-(void)modifyProgress:(id)sender
{
    float progress = [[[sender userInfo] objectForKey:@"progress"] floatValue];
    float finished = [[[sender userInfo] objectForKey:@"finished"] floatValue];
    float weight = [[[sender userInfo] objectForKey:@"weight"] floatValue];
    progress*=weight;
    if (_progressView) {
        [_progressView setProgress:progress+finished animated:YES];
    }
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.uploadImage = croppedImage;
    [self.getPhoto setBackgroundImage:croppedImage forState:UIControlStateNormal];
    self.getPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//[picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
//    self.uploadImage = image;
//    [self.getPhoto setBackgroundImage:image forState:UIControlStateNormal];
//    self.getPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [picker dismissViewControllerAnimated:NO completion:^{
        //1.裁剪图片
//        [self openEditor:image];
        
        //2.返回图片
        float ratio = image.size.width / image.size.height;
        if(ratio > 3){
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"很抱歉，不支持上传宽度过大的图片，请重新选择" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }else if(ratio < 1.0/3.0){
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"很抱歉，不支持上传高度过大的图片，请重新选择" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }else{
            self.uploadImage = image;
            [self.getPhoto setBackgroundImage:image forState:UIControlStateNormal];
            self.getPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        
    }];

}



#pragma mark - TextView delegate
-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"test");
    if ([textView.text isEqualToString:@""]) {
        [self.preLabel setEnabled:YES];
        self.preLabel.text = @"";
        [self.preLabel setEnabled:NO];
    }else{
        [self.preLabel setEnabled:YES];
        self.preLabel.text = @" ";
        [self.preLabel setEnabled:NO];
    }
    
    float offset = textView.contentSize.height - textView.frame.size.height;
    
    if (offset != 0) {
        CGRect frame = textView.frame;
        frame.size.height += offset;
        textView.frame = frame;
        
        frame = self.textView.frame;
        frame.size.height += offset;
        self.textView.frame = frame;
        
        frame = self.imgView.frame;
        frame.origin.y += offset;
        self.imgView.frame = frame;
    }


}

#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    if (imageView) {
        imageView.image = image;
    }
    else if (type == 100){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
        [dictionary setValue:self.eventId forKey:@"event_id"];
        [dictionary setValue:@"upload" forKey:@"cmd"];
        [dictionary setValue:container[0] forKey:@"photos"];
        [dictionary setValue:container[1]  forKey:@"width"];
        [dictionary setValue:container[2] forKey:@"height"];
        [dictionary setValue:self.textInput.text forKey:@"specification"];
        
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendPhotoMessage:dictionary withOperationCode: UPLOADPHOTO finshedBlock:nil];
        
        
        
    }else if (type == 106){
        [self removeWaitingView];
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:nil WithCancelTitle:@"确定"];
        [_upLoad setEnabled:YES];
    }
}




#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[response1 valueForKey:@"photo_name"]]];
            NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString* filePath = [docFolder stringByAppendingPathComponent:@"tmp.png"];
            [[SDImageCache sharedImageCache] storeImageToDisk:filePath forKey:url];
            NSFileManager* fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                [fileManager removeItemAtPath:filePath error:nil];
            }
            
            if (_progressView) {
                [_progressView setProgress:1.0 animated:YES];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeWaitingView];
                ((PictureWall2*)self.photoWallController).shouldReloadPhoto = YES;
                [self.navigationController popToViewController:self.photoWallController animated:YES];
            });
            
        }
            break;
        default:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片上传失败" WithDelegate:nil WithCancelTitle:@"确定"];
            [self removeWaitingView];
            [self.upLoad setEnabled:YES];
            [self.getPhoto setEnabled:YES];
        }
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if ([alertView tag] == 120) {
        if (buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
}


@end
