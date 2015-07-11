//
//  BannerSelectorViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BannerSelectorViewController.h"
#import "UIImage+fixOrien.h"

#import "UzysAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BannerSelectorViewController ()
@end

@implementation BannerSelectorViewController

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
    if (_code >= 2 && _code <=7) {
        [((UIImageView*)_selectorIndictors[_code-2]) setHighlighted:YES];
    }
    
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectBanner:(UIButton*)sender {
    for (int i = 0; i < _selectorIndictors.count; i++) {
        UIImageView* indictor = [_selectorIndictors objectAtIndex:i];
        [indictor setHighlighted:NO];
    }
    _code = [sender tag]+1;
    [((UIImageView*)_selectorIndictors[[sender tag] - 1]) setHighlighted:YES];
}

- (IBAction)getMyBanner:(id)sender {
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];

}


- (IBAction)confirmBanner:(id)sender {
    if (_Econtroller) {
        if (_code >= 2) {
            self.Econtroller.uploadImage = nil;
            self.Econtroller.Bannercode = _code;
        }
        [self.navigationController popToViewController:self.Econtroller animated:YES];
        return;
    }else if(_EEcontroller){
        if (_code >= 2) {
            self.EEcontroller.uploadImage = nil;
            self.EEcontroller.Bannercode = _code;
        }
        [self.navigationController popToViewController:self.EEcontroller animated:YES];
        return;

    }
    if (_Lcontroller) {
        if (_code >= 2) {
            self.Lcontroller.code = _code;
            self.Lcontroller.uploadImage = nil;
            [self.Lcontroller.banner_button setBackgroundImage:((UIButton*)self.defaultBanners[_code-2]).imageView.image forState:UIControlStateNormal];
        }

        [self.navigationController popToViewController:self.Lcontroller animated:YES];
        self.Lcontroller = nil;
    }
    
    
}

- (void)openEditor
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.uploadImage;
    
    UIImage *image = self.uploadImage;
    self.uploadImage = nil;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat wi = MIN(width, height*2.5);
    controller.imageCropRect = CGRectMake((width - wi) / 2,
                                          (height - wi*0.4) / 2,
                                          wi,
                                          wi*0.4);
    [controller setKeepingCropAspectRatio:YES];
    [controller setToolbarHidden:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
    
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* imageURL = [info valueForKey:@"UIImagePickerControllerReferenceURL"];
    if (imageURL) {
        ALAssetsLibrary *library = [UzysAssetsPickerController defaultAssetsLibrary] ;
        [library assetForURL:imageURL resultBlock:^(ALAsset *asset) {
            
            if (!asset) {
                NSLog(@"图片已不存在");
                [picker dismissViewControllerAnimated:YES completion:^{}];
                //        [self openEditor];
                //    }];
                return ;
            }
            UIImage* img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:asset.defaultRepresentation.scale orientation:0];
            self.uploadImage = img;
            [picker dismissViewControllerAnimated:YES completion:^{
                [self openEditor];
            }];
            
        } failureBlock:^(NSError *error) {
            [picker dismissViewControllerAnimated:YES completion:^{}];
        }];
    }else{
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        if (image) image = [UIImage fixOrientation:image];
        self.uploadImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor];
        }];
    }

}



#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    if (_Econtroller) {
        [controller dismissViewControllerAnimated:YES completion:^{
            self.Econtroller.uploadImage = croppedImage;
            self.Econtroller.Bannercode = 0;
            self.uploadImage = nil;
            [self.navigationController popToViewController:self.Econtroller animated:YES];
        }];
        return;
    }else if (_EEcontroller){
        [controller dismissViewControllerAnimated:YES completion:^{
            self.EEcontroller.uploadImage = croppedImage;
            self.EEcontroller.Bannercode = 0;
            self.uploadImage = nil;
            [self.navigationController popToViewController:self.EEcontroller animated:YES];
        }];
        return;
    }
    
    if (_Lcontroller) {
        [controller dismissViewControllerAnimated:YES completion:^{
            self.Lcontroller.uploadImage =croppedImage;
            [self.Lcontroller.banner_button setBackgroundImage:croppedImage forState:UIControlStateNormal];
            self.Lcontroller.code = 0;
            self.uploadImage = nil;
            [self.navigationController popToViewController:self.Lcontroller animated:YES];
        }];
        
    }
    
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
@end
