//
//  PhotoUploadViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoUploadViewController.h"
#import "../Utils/CommonUtils.h"




@interface PhotoUploadViewController ()
@property (strong, nonatomic) UITextView* textInput;
@property (strong, nonatomic) UIView* textView;
@property (strong, nonatomic) UIView* imgView;
@property (strong, nonatomic) UIImageView* img;
@property (strong, nonatomic) UIImage* uploadImage;
@property (strong, nonatomic) UIButton* getPhoto;
@property (strong, nonatomic) UIButton* upLoad;
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
    [self.preLabel setFont:[UIFont systemFontOfSize:20]];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)UesrImageClicked
{
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

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.uploadImage;

    UIImage *image = self.uploadImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }

    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self.getPhoto setBackgroundImage:croppedImage forState:UIControlStateNormal];
    self.uploadImage = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
	//[picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.uploadImage = image;
    [self.getPhoto setBackgroundImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
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
        [dictionary setValue:container forKey:@"photos"];
        [dictionary setValue:self.textInput.text forKey:@"specification"];
        
        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendPhotoMessage:dictionary withOperationCode: UPLOADPHOTO];
        
        
        
    }else if (type == 106){
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
    }
}




#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片上传成功" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
            break;
        default:
        {
            [self.upLoad setEnabled:YES];
            [self.getPhoto setEnabled:YES];
        }
    }
}
#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    // the user clicked OK
    if (buttonIndex == 0)
    {
        [self.navigationController popToViewController:self.photoWallController animated:YES];
    }
}




- (IBAction)upload:(id)sender {
    if (!self.uploadImage) {
        [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"请选择照片" WithDelegate:self WithCancelTitle:@"确定"];
    }
    self.upLoad = sender;
    [self.upLoad setEnabled:NO];
    [self.getPhoto setEnabled:NO];
    PhotoGetter *getter = [[PhotoGetter alloc]initUploadMethod:self.uploadImage type:1];
    getter.mDelegate = self;
    [getter uploadPhoto];
}
@end
