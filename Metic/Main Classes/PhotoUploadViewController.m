//
//  PhotoUploadViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoUploadViewController.h"
#import "PictureWall2.h"
#import "../Utils/CommonUtils.h"
#import "MobClick.h"
#import "../Utils/Reachability.h"
#import "BOAlertController.h"
#import "SVProgressHUD.h"
#import "UploaderManager.h"
#import "MTPhotoBrowser.h"
#import "MJPhoto.h"

static const NSInteger MaxUploadCount = 20;

@interface PhotoUploadViewController ()<MTPhotoBrowserDelegate>
@property (strong, nonatomic) UITextView* textInput;
@property (strong, nonatomic) UIView* textView;
@property (strong, nonatomic) UICollectionView* imgCollectionView;
@property (strong, nonatomic) NSMutableArray* uploadImgs;
@property (strong, nonatomic) NSMutableArray* uploadImgAssets;
@property (strong, nonatomic) UITextField* preLabel;

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
    [self pickPhotos];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    MTLOG(@"dealloc");
}

//返回上一层
-(void)MTpopViewController{
    if(self.uploadImgs.count){
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
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(60,70);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.imgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.textView.frame) + 15, 290, 80) collectionViewLayout:flowLayout];
    self.imgCollectionView.layer.cornerRadius = 5;
    self.imgCollectionView.layer.masksToBounds = YES;
    [self.imgCollectionView setBackgroundColor:[UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1]];
    self.imgCollectionView.showsVerticalScrollIndicator = NO;
    self.imgCollectionView.dataSource = self;
    self.imgCollectionView.delegate = self;
    [self.imgCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"uploadImgCell"];
    [self.scrollView addSubview:self.imgCollectionView];
    
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

-(void)MTdismissKeyboard
{
    [_textInput becomeFirstResponder];
    [_textInput resignFirstResponder];
}

- (IBAction)upload:(id)sender {
    [sender setEnabled:NO];

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
    [[UploaderManager sharedManager] uploadALAssets:_uploadImgAssets eventId:_eventId imageDescription:[self.textInput.text copy]];
    
    [SVProgressHUD showSuccessWithStatus:@"图片已加入到上传队列" duration:2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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

#pragma mark - TextView delegate
-(void)textViewDidChange:(UITextView *)textView
{
    MTLOG(@"test");
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
    
    if (offset != 0 && CGRectGetHeight(textView.frame) < 100) {
        CGRect frame = textView.frame;
        frame.size.height += offset;
        textView.frame = frame;
        
        frame = self.textView.frame;
        frame.size.height += offset;
        self.textView.frame = frame;
        
        frame = self.imgCollectionView.frame;
        frame.origin.y += offset;
        self.imgCollectionView.frame = frame;
        [self adjustCollectionView];
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
    //多图上传
    if (_uploadImgs.count >= MaxUploadCount) {
        return _uploadImgs.count;
    }
    return _uploadImgs.count + 1;
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
        //多图上传
        UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
        picker.delegate = self;
        NSInteger maximumNumber = _uploadImgAssets.count >= MaxUploadCount? 0:MaxUploadCount - _uploadImgAssets.count;
        picker.maximumNumberOfSelectionVideo = 0;
        picker.maximumNumberOfSelectionPhoto = maximumNumber;
        
        [self presentViewController:picker animated:YES completion:^{}];

        
    }else {
        //多图上传
        MTLOG(@"showPhotos");
        NSInteger count = self.uploadImgs.count;
        if (count == 0) return;
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < self.uploadImgs.count; i++)
        {
            
            UICollectionViewCell* cell = [self.imgCollectionView cellForItemAtIndexPath:indexPath];
            MJPhoto *photo = [[MJPhoto alloc] init];
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
    MTLOG(@"%@",assets);
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
