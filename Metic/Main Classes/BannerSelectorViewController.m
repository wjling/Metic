//
//  BannerSelectorViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-29.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BannerSelectorViewController.h"

@interface BannerSelectorViewController ()
@property int code;
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
    [CommonUtils addLeftButton:self];
    _code = 1;
    // Do any additional setup after loading the view.
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

- (IBAction)selectBanner:(id)sender {
    for (UIImageView* indictor in _selectorIndictors) {
        [indictor setHighlighted:NO];
    }
    _code = [sender tag];
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
    if(self.controller.code!=0){
        self.controller.code = _code;
        [self.controller.banner_button setBackgroundImage:((UIButton*)self.defaultBanners[_code-1]).imageView.image forState:UIControlStateNormal];
    }
    [self.navigationController popToViewController:self.controller animated:YES];
    self.controller = nil;
}

- (void)openEditor
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.uploadImage;
    
    UIImage *image = self.uploadImage;
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
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.uploadImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
    
}



#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.controller.uploadImage =croppedImage;
    [self.controller.banner_button setBackgroundImage:croppedImage forState:UIControlStateNormal];
    self.controller.code = 0;
    self.uploadImage = nil;
    [self.navigationController popToViewController:self.controller animated:YES];
    self.controller = nil;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
@end
