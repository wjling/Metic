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
#import "UIImage+fixOrien.h"
#import "photoProcesser.h"
#import "SVProgressHUD.h"
#import "UploaderManager.h"
#import "MTPhotoBrowser.h"
#import "MJPhoto.h"


static const CGSize progressViewSize = { 200.0f, 30.0f };
static const NSInteger MaxUploadCount = 20;
static const BOOL canMutiUpload = NO;


@interface PhotoUploadViewController ()<MTPhotoBrowserDelegate>
@property (strong, nonatomic) UITextView* textInput;
@property (strong, nonatomic) UIView* textView;
@property (strong, nonatomic) UIView* imgView;
@property (strong, nonatomic) UICollectionView* imgCollectionView;
@property (strong, nonatomic) NSMutableArray* uploadImgs;
@property (strong, nonatomic) NSMutableArray* uploadImgAssets;
@property (strong, nonatomic) UIImageView* img;
@property (strong, nonatomic) UIImage* uploadImage;
@property (strong, nonatomic) UIButton* getPhoto;
@property (strong, nonatomic) UIButton* upLoad;
@property (strong, nonatomic) UITextField* preLabel;
@property (strong, nonatomic) UIView* waitingView;
@property (strong, nonatomic) THProgressView *progressView;
@property (strong, nonatomic) NSMutableSet *deleteIndexs;

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
    [self initData];
    [self initUI];
    //多图上传
    if (canMutiUpload) {
        [self pickPhotos];
    }
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"图片上传"];
    [_imgCollectionView reloadData];
    
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

-(void)dealloc
{
    NSLog(@"dealloc");
}

//返回上一层
-(void)MTpopViewController{
    if(_uploadImage){
        [self alertConfirmQuit];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initData
{
    _uploadImgs = [[NSMutableArray alloc]init];
    _uploadImgAssets = [[NSMutableArray alloc]init];
}

-(void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self drawLeftButton];
    self.scrollView.delegate = self;
    
//    _textView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 290, 36)];
//    [_textView setBackgroundColor:[UIColor whiteColor]];
//    _textView.layer.cornerRadius = 5;
//    _textView.layer.masksToBounds = YES;
//    [self.scrollView addSubview:_textView];
//    
//    self.textInput = [[UITextView alloc]initWithFrame:CGRectMake(8, 0, 274, 36)];
//    self.textInput.delegate = self;
//    [self.textInput setBackgroundColor:[UIColor clearColor]];
//    [self.textInput setFont:[UIFont systemFontOfSize:16]];
//    [_textView addSubview:self.textInput];
//    
//    self.preLabel = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, 274, 36)];
//    [self.preLabel setPlaceholder:@"这一刻的想法"];
//    [self.preLabel setBackgroundColor:[UIColor clearColor]];
//    [self.preLabel setEnabled:NO];
//    self.preLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [self.preLabel setFont:[UIFont systemFontOfSize:18]];
//    [_textView addSubview:self.preLabel];
    
    
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(60,70);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.imgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 15, 290, 80) collectionViewLayout:flowLayout];
    self.imgCollectionView.layer.cornerRadius = 5;
    self.imgCollectionView.layer.masksToBounds = YES;
    [self.imgCollectionView setBackgroundColor:[UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1]];
    self.imgCollectionView.showsVerticalScrollIndicator = NO;
    self.imgCollectionView.dataSource = self;
    self.imgCollectionView.delegate = self;
    [self.imgCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"uploadImgCell"];
    [self.scrollView addSubview:self.imgCollectionView];
    
    
    
    
    
    
    
    
    
    
    //    self.imgView =  [[UIView alloc] initWithFrame:CGRectMake(15, 66, 290, 78)];
    //    self.imgView.layer.cornerRadius = 5;
    //    self.imgView.layer.masksToBounds = YES;
    //    [self.imgView setBackgroundColor:[UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1]];
    //    [self.scrollView addSubview:self.imgView];
    //
    //    self.getPhoto = [UIButton buttonWithType:UIButtonTypeSystem];
    //    [self.getPhoto setFrame:CGRectMake(10, 9, 60 , 60)];
    //    [self.getPhoto setBackgroundImage:[UIImage imageNamed:@"加图片的加号"] forState:UIControlStateNormal];
    //    [self.getPhoto addTarget:self action:@selector(UesrImageClicked) forControlEvents:UIControlEventTouchUpInside];
    //    [self.imgView addSubview:self.getPhoto];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MTdismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
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
        NSLog(@"cancel");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
    [actionSheet addButton:cancelItem type:RIButtonItemType_Cancel];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        RIButtonItem *takeItem = [RIButtonItem itemWithLabel:@"拍照" action:^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
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
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    [actionSheet addButton:seleteItem type:RIButtonItemType_Other];

    [actionSheet showInView:self.view];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
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
    [sender setEnabled:NO];
    
    if (canMutiUpload) {
        //多图上传
        if (_uploadImgs.count == 0) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"请选择图片" WithDelegate:nil WithCancelTitle:@"确定"];
            [sender setEnabled:YES];
            return;
        }
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0){
            [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"未连接网络" WithDelegate:nil WithCancelTitle:@"确定"];
            [sender setEnabled:YES];
            return;
        }
        [[UploaderManager sharedManager] uploadALAssets:_uploadImgAssets eventId:_eventId];
        
        [SVProgressHUD showSuccessWithStatus:@"图片已加入到上传队列" duration:2];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else{
        //单图上传
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
    
}

-(void)pickPhotos
{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    NSInteger maximumNumber = _uploadImgAssets.count >= MaxUploadCount? 0:MaxUploadCount - _uploadImgAssets.count;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = maximumNumber;
    
    [self presentViewController:picker animated:YES completion:^{}];
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
        
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
        [[UIApplication sharedApplication].keyWindow addSubview:_waitingView];
    }
}

-(void)removeWaitingView
{
    if (_waitingView) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
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
    if (image) image = [UIImage fixOrientation:image];
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
            [_uploadImgs addObject:image];
            [_imgCollectionView reloadData];
            [self adjustCollectionView];
            self.uploadImage = image;
//            [self.getPhoto setBackgroundImage:image forState:UIControlStateNormal];
//            self.getPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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

#pragma mark - CollectionViewDelegate

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (canMutiUpload) {
        //多图上传
        if (_uploadImgs.count >= MaxUploadCount) {
            return _uploadImgs.count;
        }
        return _uploadImgs.count + 1;
    }else{
        //单图上传
        return 1;
    }
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"uploadImgCell" forIndexPath:indexPath];
    [cell setHidden:NO];
    UIImageView* imgCell = (UIImageView*)[cell viewWithTag:1];
    if (!imgCell) {
        imgCell = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        imgCell.contentMode = UIViewContentModeScaleAspectFill;
        imgCell.layer.cornerRadius = 3;
        imgCell.layer.masksToBounds = YES;
        imgCell.clipsToBounds = YES;
        [imgCell setTag:1];
        [cell addSubview:imgCell];
    }
    
    if(indexPath.row != _uploadImgs.count){
        [imgCell setImage:_uploadImgs[indexPath.row]];
        
    }else{
        [imgCell setImage:[UIImage imageNamed:@"加图片的加号"]];
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textInput resignFirstResponder];
    if (indexPath.row == _uploadImgs.count) {
        if (canMutiUpload) {
            //多图上传
            UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
            picker.delegate = self;
            NSInteger maximumNumber = _uploadImgAssets.count >= MaxUploadCount? 0:MaxUploadCount - _uploadImgAssets.count;
            picker.maximumNumberOfSelectionVideo = 0;
            picker.maximumNumberOfSelectionPhoto = maximumNumber;
            
            [self presentViewController:picker animated:YES completion:^{}];
        }else{
            //单图上传
            [self UesrImageClicked];
        }
        
    }else if (canMutiUpload){
        //多图上传
        NSLog(@"showPhotos");
        NSInteger count = self.uploadImgs.count;
        _deleteIndexs = [[NSMutableSet alloc]init];
        if (count == 0) return;
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < self.uploadImgs.count; i++)
        {
            
            UICollectionViewCell* cell = [self.imgCollectionView cellForItemAtIndexPath:indexPath];
            MJPhoto *photo = [[MJPhoto alloc] init];
            //            UIImage* img = _uploadImgs[i];
            //            photo.image = img;
            ALAsset* asset = _uploadImgAssets[i];
            photo.asset = asset;
            photo.srcImageView = (UIImageView*)[cell viewWithTag:1]; // 来源于哪个UIImageView
            photo.isSelected = YES;
            [photos addObject:photo];
            
        }
        
        // 2.显示相册
        MTPhotoBrowser *browser = [[MTPhotoBrowser alloc] init];
        browser.shouldDelete = YES;
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        browser.delegate = self;
        [browser show];
    }
}

-(void)adjustCollectionView
{
    CGRect frame = _imgCollectionView.frame;
    float count = _uploadImgs.count+1;
    if (count > MaxUploadCount) count = MaxUploadCount;
    frame.size.height = ceilf(count/4)*70 + 10;
    while (CGRectGetMaxY(frame) > CGRectGetMaxY(self.scrollView.frame) ) {
        frame.size.height -= 70;
    }
    _imgCollectionView.frame = frame;
}

#pragma - UzysAssetsPickerController Delegate
-(void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) weakSelf = self;
        __block NSInteger invalidPhotos = 0;
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            if ([[representation valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) {
                UIImage *img = [UIImage imageWithCGImage:representation.aspectRatioThumbnail];
                float ratio = img.size.width / img.size.height;
                if(ratio > 1.0/3.0 && ratio < 3){
                    [weakSelf.uploadImgs addObject:img];
                    [self.uploadImgAssets addObject:representation];
                }else  invalidPhotos++;
            }
            
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_imgCollectionView reloadData];
            [self adjustCollectionView];
            if (invalidPhotos > 0) {
                [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:[NSString stringWithFormat:@"很抱歉，检测到 %ld 张图片的长宽比过大或者文件不存在，请重新选择",(long)invalidPhotos] WithDelegate:nil WithCancelTitle:@"确定"];
            }
            
        });
    });
    
    
    NSLog(@"%@",assets);
}

-(void)UzysAssetsPickerControllerDidCancel:(UzysAssetsPickerController *)picker
{
    
}

#pragma mark - UIGestureRecognizer Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view.superview isKindOfClass:[UICollectionViewCell class]]){
        return NO;
    }
    else return YES;
    
}

#pragma mark - MTPhotoBrowserDelegate
-(void)photoBrowser:(MTPhotoBrowser *)photoBrowser didSelectPageAtIndex:(NSUInteger)index
{
    NSLog(@"%d",index);
    if (index < _uploadImgs.count) {
        [_uploadImgs removeObjectAtIndex:index];
    }
    if (index < _uploadImgAssets.count) {
        [_uploadImgAssets removeObjectAtIndex:index];
    }
    [_imgCollectionView reloadData];
    [self adjustCollectionView];
}

-(void)willDismissBrowser:(MTPhotoBrowser *)photoBrowser
{
    [_imgCollectionView reloadData];
    [self adjustCollectionView];
}

@end
