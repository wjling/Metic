//
//  MTPhotoToolbar.m
//  WeShare
//
//  Created by 俊健 on 15/4/5.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "MTPhotoToolbar.h"
#import "MJPhoto.h"
#import "MBProgressHUD+Add.h"
#import "MTPhotoBrowser.h"

@interface MTPhotoToolbar()
{
    // 显示页码
    UILabel *_indexLabel;
    UIButton *_saveImageBtn;
    UIButton *_backBtn;
    UIButton *_selectBtn;
}
@end

@implementation MTPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 1 && !_indexLabel) {
        CGRect frame = self.bounds;
        frame.origin.y += 20;
        frame.size.height -= 20;
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = frame;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    // 保存图片按钮
    CGFloat btnWidth = self.bounds.size.height;
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    //    [self addSubview:_saveImageBtn];
    

    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, 20, 70, btnWidth - 20);
    _backBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_backBtn setImage:[UIImage imageNamed:@"头部左上角图标-返回"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];
    
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(250, 20, 70, btnWidth - 20);
    _selectBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (_shouldDelete) {
        [_selectBtn setImage:[UIImage imageNamed:@"删除图标"] forState:UIControlStateNormal];
    }else{
        [_selectBtn setImage:[UIImage imageNamed:@"预览效果选中"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"预览效果未选中"] forState:UIControlStateHighlighted];
    }
    
    [_selectBtn addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectBtn];
}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)back
{
    if (self.browser) {
        [self.browser quit];
    }
    
}

- (void)selectPhoto
{
    
    if (self.browser) {
        if ([self.browser.delegate respondsToSelector:@selector(photoBrowser:didSelectPageAtIndex:)]) {
            [self.browser.delegate photoBrowser:self.browser didSelectPageAtIndex:_currentPhotoIndex];
        }
    }
    MJPhoto* photo = _photos[_currentPhotoIndex];
    if (self.shouldDelete && photo.isSelected) {
        if (self.browser.photos.count > 1) {
            [self.browser removePhotoViewAtIndex:_currentPhotoIndex];
        }else{
            //退出
            [self back];
        }
        return;
    }
    if (photo) {
        photo.isSelected = !photo.isSelected;
        [self refreshSelectBtn];
    }
    
}

- (void)refreshSelectBtn
{
    MJPhoto* photo = _photos[_currentPhotoIndex];
    if (photo && !self.shouldDelete) {
        if (photo.isSelected) {
            [_selectBtn setImage:[UIImage imageNamed:@"预览效果选中"] forState:UIControlStateNormal];
        }else{
            [_selectBtn setImage:[UIImage imageNamed:@"预览效果未选中"] forState:UIControlStateNormal];
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        MJPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", _currentPhotoIndex + 1, _photos.count];
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    // 按钮
    _saveImageBtn.enabled = photo.image != nil && !photo.save;
    
    //更新选择按钮
    [self refreshSelectBtn];
}

@end

