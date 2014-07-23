//
//  ScanViewController.h
//  Metic
//
//  Created by ligang_mac4 on 14-7-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface ScanViewController : UIViewController<ZBarReaderViewDelegate>
{
    IBOutlet UILabel  * label ;
    IBOutlet ZBarReaderView *readerView;
    ZBarCameraSimulator *cameraSim;
}

@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property(nonatomic,retain) UILabel * label ;
@property (nonatomic, retain) ZBarReaderView *readerView;

@end
