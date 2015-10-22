//
//  AvatarViewController.m
//  WeShare
//
//  Created by 俊健 on 15/6/24.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "AvatarViewController.h"
#import "CommonUtils.h"
#import "UIImageView+MTWebCache.h"
#import "PhotoGetter.h"
#import "SVProgressHUD.h"
#import "BOAlertController.h"
#import "RIButtonItem.h"
#import "PECropViewController.h"
#import "UIImage+fixOrien.h"
#import "UIImage+squareThumbail.h"
#import "MTOperation.h"
#import "MegUtils.h"
#import "UzysAssetsPickerController.h"

@interface AvatarViewController ()<UIImagePickerControllerDelegate,PECropViewControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) UIImageView* avatar;
@end

@implementation AvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.96f alpha:1.0f];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    CGRect frame = self.view.frame;
    _avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame))];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_avatar];
    
    CGFloat gap = ((CGRectGetMaxY(frame) - CGRectGetWidth(frame)) - 45*2)/3;
    
    UIButton* changeAvatar = [UIButton buttonWithType:UIButtonTypeCustom];
    changeAvatar.frame = CGRectMake(20, CGRectGetWidth(frame)+ (gap > 40? gap + (gap-40)/2:gap), CGRectGetWidth(frame)-40, 45);
    changeAvatar.layer.cornerRadius = 3;
    changeAvatar.layer.masksToBounds = YES;
    [changeAvatar setTitle:@"更换头像" forState:UIControlStateNormal];
    [changeAvatar setTitleColor:[UIColor colorWithWhite:0.99f alpha:1.0f] forState:UIControlStateNormal];
    [changeAvatar.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [changeAvatar setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [changeAvatar setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:68/255.0 green:162/255.0 blue:137/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    [changeAvatar addTarget:self action:@selector(uploadAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeAvatar];
    
    UIButton* save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.frame = CGRectMake(20, CGRectGetMaxY(changeAvatar.frame)+ (gap > 40? 40:gap), CGRectGetWidth(frame)-40, 45);
    save.layer.cornerRadius = 3;
    save.layer.masksToBounds = YES;
    [save setTitle:@"保存到相册" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor colorWithWhite:0.05f alpha:1.0f] forState:UIControlStateNormal];
    [save.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [save setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.99f alpha:1.0f]] forState:UIControlStateNormal];
    [save setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.97f alpha:1.0f]] forState:UIControlStateHighlighted];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:save];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    tapRecognizer.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tapRecognizer];
    
}

- (void)initData
{
    NSString* path = [MegUtils avatarImagePathWithUserId:[MTUser sharedInstance].userid];
    NSString* path_HD = [MegUtils avatarHDImagePathWithUserId:[MTUser sharedInstance].userid];
    
    [[MTOperation sharedInstance] getUrlFromServer:path success:^(NSString *url) {
        
        [_avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"] cloudPath:path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
    } failure:^(NSString *message) {
        MTLOG(@"message");
        _avatar.image = [UIImage imageNamed:@"默认用户头像"];
    }];
    
    [[MTOperation sharedInstance] getUrlFromServer:path_HD success:^(NSString *url) {
        
        [_avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"] cloudPath:path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
    } failure:^(NSString *message) {
        MTLOG(@"message");
        [UIImage imageNamed:@"默认用户头像"];
    }];

}

-(void)refresh
{
    [self initData];
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)uploadAvatar:(id)sender
{
    [self avatarClicked:nil];
}

-(void)avatarClicked:(id)sender
{
    MTLOG(@"avatar clicked");
    BOAlertController *actionSheet = [[BOAlertController alloc] initWithTitle:@"选择图像" message:nil viewController:self];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
        MTLOG(@"cancel");
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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldIgnoreTurnToNotifiPage"];
    [actionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
    if (referenceURL) {
        [[UzysAssetsPickerController defaultAssetsLibrary] assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            
            if (!asset) {
                MTLOG(@"图片已不存在");
                [picker dismissViewControllerAnimated:YES completion:NULL];
                return ;
            }
            UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage
                                               scale:asset.defaultRepresentation.scale
                                         orientation:0];
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor:img];
            }];
        } failureBlock:^(NSError *error) {
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }];
    } else {
        [[UzysAssetsPickerController defaultAssetsLibrary] writeImageToSavedPhotosAlbum:image.CGImage metadata:info[UIImagePickerControllerMediaMetadata] completionBlock:^(NSURL *assetURL, NSError *error) {
            [[UzysAssetsPickerController defaultAssetsLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                if (!asset) {
                    MTLOG(@"图片已不存在");
                    [picker dismissViewControllerAnimated:YES completion:NULL];
                    return ;
                }
                UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage
                                                   scale:asset.defaultRepresentation.scale
                                             orientation:0];
                [picker dismissViewControllerAnimated:YES completion:^{
                    [self openEditor:img];
                }];
            } failureBlock:^(NSError *error) {
                [picker dismissViewControllerAnimated:YES completion:NULL];
            }];
        }];
    }
}

- (void)openEditor:(UIImage*)image
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    [controller setKeepingCropAspectRatio:YES];
    [controller setToolbarHidden:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
}

-(void)save
{
    NSString* path = [NSString stringWithFormat:@"/avatar/%@.jpg",[MTUser sharedInstance].userid];
    NSString* path_HD = [NSString stringWithFormat:@"/avatar/%@_2.jpg",[MTUser sharedInstance].userid];
    
    [[MTOperation sharedInstance] getUrlFromServer:path_HD success:^(NSString *url) {
        if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:url]) {
            UIImageWriteToSavedPhotosAlbum([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:url],self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
        }else{
            [[MTOperation sharedInstance] getUrlFromServer:path success:^(NSString *url) {
                if ([[SDImageCache sharedImageCache]diskImageExistsWithKey:url]) {
                    UIImageWriteToSavedPhotosAlbum([[SDImageCache sharedImageCache]imageFromDiskCacheForKey:url],self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
                }
                
            } failure:^(NSString *message) {
                MTLOG(@"message");
            }];
        }
        
    } failure:^(NSString *message) {
        MTLOG(@"message");
    }];
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    if (error){
        // Do anything needed to handle the error or display it to the user
    }else{
        [SVProgressHUD showSuccessWithStatus:@"保存成功" duration:0.7f];
    }
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
    PhotoGetter* getter = [[PhotoGetter alloc]initUploadAvatarMethod:croppedImage type:21 viewController:self];
    [getter uploadAvatar];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldIgnoreTurnToNotifiPage"];
    }];
}


@end
