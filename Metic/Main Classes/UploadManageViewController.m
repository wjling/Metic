//
//  UploadManageViewController.m
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UploadManageViewController.h"
#import "UploadManageViewCell.h"
#import "MTDatabaseHelper.h"
#import "MTUser.h"

@interface UploadManageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong) UILabel* emptyAlert;


@end

@implementation UploadManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self fixUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI
{
    [self.navigationItem setTitle:@"上传中"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(96,110);
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collelctionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 5, 300, self.view.bounds.size.height - 5) collectionViewLayout:flowLayout];
    [self.collelctionView setBackgroundColor:[UIColor whiteColor]];
    self.collelctionView.showsVerticalScrollIndicator = NO;
    self.collelctionView.dataSource = self;
    self.collelctionView.delegate = self;
    [self.collelctionView registerClass:[UploadManageViewCell class] forCellWithReuseIdentifier:@"uploadManageCell"];
    [self.view addSubview:self.collelctionView];
}

-(void)initData
{
    [self pullUploadTasksfromDB];
}

-(void)fixUI
{
    [_collelctionView setFrame:CGRectMake(10, 5, 300, self.view.bounds.size.height - 5)];
}

- (void)pullUploadTasksfromDB
{
    //多图上传
    
    NSArray *seletes = [[NSArray alloc]initWithObjects:@"event_id",@"imgName",@"alasset",@"width",@"height",@"imageDescription", nil];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ order by id",_eventId],@"event_id", nil];
    [[MTDatabaseHelper sharedInstance]queryTable:@"uploadIMGtasks" withSelect:seletes andWhere:wheres completion:^(NSMutableArray *resultsArray) {
        for (int i = 0; i < resultsArray.count; i++) {
            NSDictionary *task = resultsArray[i];
            NSString* imageName = [task valueForKey:@"imgName"];
            NSMutableDictionary *uploadTask = [[NSMutableDictionary alloc]initWithDictionary:task];
            [uploadTask setValue:[NSNumber numberWithInteger:0] forKey:@"photo_id"];
            [uploadTask setValue:imageName forKey:@"url"];
            [resultsArray replaceObjectAtIndex:i withObject:uploadTask];
        }
        
        if(!_uploadingPhotos) _uploadingPhotos = [[NSMutableArray alloc]init];
        [_uploadingPhotos removeAllObjects];
        [_uploadingPhotos addObjectsFromArray:resultsArray];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collelctionView reloadData];
        });
    }];
    
    
}

-(void)refreshEmptyAlert
{
    if(!_emptyAlert){
        _emptyAlert = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        [_emptyAlert setFont:[UIFont systemFontOfSize:15]];
        [_emptyAlert setTextAlignment:NSTextAlignmentCenter];
        [_emptyAlert setTextColor:[UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1]];
        _emptyAlert.text = @"没有上传任务了哦～";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_uploadingPhotos.count) {
            [_emptyAlert removeFromSuperview];
        }else{
            [self.view addSubview:_emptyAlert];
        }
    });
}

#pragma mark - CollectionViewDelegate

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self refreshEmptyAlert];
    return _uploadingPhotos.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"uploadManageCell";
    UploadManageViewCell *cell = (UploadManageViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UploadManageViewCell alloc] init];
    }
    NSMutableDictionary* dict = _uploadingPhotos[indexPath.row];
    cell.uploadManagerView = self;
    [cell applyData:dict];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
