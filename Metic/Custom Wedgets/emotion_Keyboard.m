//
//  emotion_Keyboard.m
//  WeShare
//
//  Created by ligang_mac4 on 14-8-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "emotion_Keyboard.h"
#import "../Utils/CommonUtils.h"

@interface emotion_Keyboard ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *emotionCollection;
@property (nonatomic,strong) NSDictionary* emotionImgDictionary;
@property (nonatomic,strong) NSArray* emotionImgArray;
@end


@implementation emotion_Keyboard
-(id)init{
    self = [super init];
    if (self) {
        [self initCollectionView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCollectionView];
    }
    return self;
}

-(id)initWithPoint:(CGPoint)point
{
    CGRect frame = CGRectMake(point.x, point.y, 320, 200);
    self = [super initWithFrame:frame];
    if (self) {
        [self initCollectionView];
    }
    return self;
}

-(void)initCollectionView
{
    _emotionImgDictionary = [CommonUtils dictionaryFromFile:@"expressionImage.plist"];
    _emotionImgArray = [CommonUtils arrayFromFile:@"expression.plist"];
    
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(45,50);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _emotionCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 320, 200) collectionViewLayout:flowLayout];
    
    
    _emotionCollection.delegate = self;
    _emotionCollection.dataSource = self;
    
    
    
    [_emotionCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"emotionCell"];
    [_emotionCollection setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:_emotionCollection];
    [_emotionCollection reloadData];
}



#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 28;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emotionCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, 45, 50)];
    }
    [cell setHidden:NO];
    UIImageView* emotion;
    if ([cell viewWithTag:25] && [[cell viewWithTag:25]isKindOfClass:[UIImageView class]]) {
        emotion = (UIImageView*)[cell viewWithTag:25];
    }else{
        emotion = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 36, 36)];
        UIImage* emotionImg = nil;
        if (indexPath.row < 27) emotionImg = [UIImage imageNamed:[_emotionImgDictionary valueForKey: _emotionImgArray[indexPath.row]]];
        else emotionImg = [UIImage imageNamed:@"ic_content_backspace"];
        
        [emotion setImage:emotionImg];
        [cell addSubview:emotion];
        [cell setTag:25];
    }
    [emotion setUserInteractionEnabled:NO];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row < 27){
        UIImageView* emotion = (UIImageView*)[cell viewWithTag:25];
        if (emotion) {
            
            NSString* emotionExpression = _emotionImgArray[indexPath.row];
            if (_textField) _textField.text = [_textField.text stringByAppendingString:emotionExpression];
            if (_textView) _textView.text = [_textView.text stringByAppendingString:emotionExpression];
        }
    }else NSLog(@"删除一个表情 或一个字符");
}









@end
