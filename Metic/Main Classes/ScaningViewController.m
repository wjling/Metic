//
//  ScaningViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-19.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "ScaningViewController.h"

@interface ScaningViewController ()
@property(nonatomic,strong)ZBarReaderViewController * reader;
@end

@implementation ScaningViewController

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
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scan:(id)sender {
    
    
    _reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
    [self setcameraOverlayView:_reader];
    ZBarImageScanner * scanner = _reader.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [_reader.readerView setTorchMode:0];
    [_reader setShowsZBarControls:NO];
    
    [self.navigationController pushViewController:_reader animated:YES];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol * symbol;
    for(symbol in results)
        break;
    
    _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.navigationController popToViewController:self animated:YES];
    //[picker dismissViewControllerAnimated:YES completion:nil];
    
    _label.text = symbol.data;
}






#pragma mark – 自定义扫描界面
- (void)setcameraOverlayView:(ZBarReaderViewController *)reader
{
    
    //清除原有控件
    
    for (UIView *temp in [reader.view subviews]) {

        for (UIToolbar *toolbar in [temp subviews]) {
            
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                UIButton* help = [toolbar subviews][1];
                if ([help isKindOfClass:[UIButton class]]) {
                    [help setHidden:YES];
                    [help removeFromSuperview];
                }

                [toolbar setHidden:YES];

                [toolbar removeFromSuperview];
                
            }
            
            
        }
        
    }
    
    //画中间的基准线
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(60, CGRectGetMidY( reader.view.frame), 200, 1)];
    
    line.backgroundColor = [UIColor redColor];
    
    [reader.view addSubview:line];
    
    
    //最上部view
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280,CGRectGetMidY( reader.view.frame)-140)];
    
    upView.alpha = 0.8;
    
    upView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:upView];
    
    
    //左侧的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, reader.view.frame.size.height+30)];
    
    leftView.alpha = 0.8;
    
    leftView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:leftView];
    
    
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 20, reader.view.frame.size.height+30)];
    
    rightView.alpha = 0.8;
    
    rightView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:rightView];
    
    
    
    //底部view
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMidY( reader.view.frame)+140, 280,  CGRectGetMidY( reader.view.frame)-110)];
    
    downView.alpha = 0.8;
    
    downView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:downView];
    
    
    //用于说明的label
    
    UILabel * labIntroudction= [[UILabel alloc] init];
    
    labIntroudction.backgroundColor = [UIColor clearColor];
    
    labIntroudction.frame=CGRectMake(0, 20, 280, 50);
    
    labIntroudction.numberOfLines=2;
    
    labIntroudction.textColor=[UIColor whiteColor];
    
    labIntroudction.text=@"请将取景框对准二维码";
    
    [labIntroudction setTextAlignment:NSTextAlignmentCenter];
    
    [downView addSubview:labIntroudction];
    
    
    

}




#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}
-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        [self.view bringSubviewToFront:self.shadowView];
        [self.shadowView setAlpha:distance/400.0];
    }else{
        //self.shadowView.hidden = YES;
        //[self.view sendSubviewToBack:self.shadowView];
    }
}


@end
