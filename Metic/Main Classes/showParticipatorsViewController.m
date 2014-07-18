//
//  showParticipatorsViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "showParticipatorsViewController.h"
#import "InviteFriendViewController.h"
#import "../Utils/PhotoGetter.h"

@interface showParticipatorsViewController ()
@property (nonatomic,strong) NSMutableSet *inviteFids;
@end

@implementation showParticipatorsViewController

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
    self.inviteFids = [[NSMutableSet alloc]initWithArray:self.fids];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _fids.count + 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"participatorCell" forIndexPath:indexPath];
    if(indexPath.row != _fids.count){
        UIImageView* avatar = (UIImageView*)[cell viewWithTag:1];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        avatar.layer.masksToBounds = YES;
        [avatar.layer setCornerRadius:5];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:_fids[indexPath.row]];
        [getter getPhoto];

    }else{
        UIImageView* add = (UIImageView*)[cell viewWithTag:1];
        [add setImage:[UIImage imageNamed:@"加图片的加号"]];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _fids.count) {
        [self performSegueWithIdentifier:@"inviteFriends" sender:self];
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.destinationViewController isKindOfClass:[InviteFriendViewController class]]) {
        InviteFriendViewController *nextViewController = segue.destinationViewController;
        nextViewController.FriendsIds = self.inviteFids;
    }

}



@end
