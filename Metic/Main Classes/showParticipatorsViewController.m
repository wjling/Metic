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
@property (nonatomic,strong) NSMutableArray* participants;
@property BOOL isRemoving;
@property BOOL isManaging;
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
    if(_canManage) [_manage_Button setHidden:NO];
    else [_manage_Button setHidden:YES];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    _fids = [[NSMutableArray alloc]init];
    _participants = [[NSMutableArray alloc]init];
    //self.inviteFids = [[NSMutableSet alloc]initWithArray:self.fids];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self getEventParticipants];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    _isManaging = NO;
    _isRemoving = NO;
    [_collectionView reloadData];
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

- (IBAction)manage:(id)sender {
    if (!_isManaging) {
        _isManaging = YES;
        _isRemoving = NO;
    }else{
        _isManaging = NO;
    }
    [self.collectionView reloadData];
}

-(void)getEventParticipants
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:_eventId forKey:@"event_id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENT_PARTICIPANTS];
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
            
            [_participants removeAllObjects];
            [_participants addObjectsFromArray:(NSArray*)[response1 valueForKey:@"participant"]];
            [_fids removeAllObjects];
            for (NSDictionary* participant in _participants) {
                [_fids addObject:[participant valueForKey:@"id"]];
            }
            [_collectionView reloadData];
        }
            break;
    }
}

#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!_isManaging) return _participants.count;
    else{
        if (_isMine) return _participants.count + 2;
        else return _visibility? _participants.count + 1:_participants.count;
    }
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"participatorCell" forIndexPath:indexPath];
    if(indexPath.row < _participants.count){
        NSDictionary* participant = _participants[indexPath.row];
        UIImageView* avatar = (UIImageView*)[cell viewWithTag:1];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[participant valueForKey:@"id"]];
        [getter getAvatar];
        name.text = [participant valueForKey:@"name"];
        [[cell viewWithTag:3] setHidden:NO];
        if (_isRemoving) {
            [[cell viewWithTag:4] setHidden:NO];
        }else [[cell viewWithTag:4] setHidden:YES];

    }else if (indexPath.row == _participants.count){
        UIImageView* add = (UIImageView*)[cell viewWithTag:1];
        [add setImage:[UIImage imageNamed:@"添加图标"]];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        name.text = @"";
        [[cell viewWithTag:4] setHidden:YES];//delete icon
        [[cell viewWithTag:3] setHidden:YES];//mask
    }else{
        UIImageView* add = (UIImageView*)[cell viewWithTag:1];
        [add setImage:[UIImage imageNamed:@"grid_remove"]];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        name.text = @"";
        [[cell viewWithTag:4] setHidden:YES];//delete icon
        [[cell viewWithTag:3] setHidden:YES];//mask
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _participants.count) {
        [self performSegueWithIdentifier:@"inviteFriends" sender:self];
    }else if(indexPath.row == _participants.count + 1){
        self.isRemoving = !_isRemoving;
        [self.collectionView reloadData];
    }
}

#pragma mark 用segue跳转时传递参数eventid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //这里我很谨慎的对sender和目标视图控制器作了判断
    if ([segue.destinationViewController isKindOfClass:[InviteFriendViewController class]]) {
        InviteFriendViewController *nextViewController = segue.destinationViewController;
        self.inviteFids = [[NSMutableSet alloc]initWithArray:self.fids];
        nextViewController.FriendsIds = self.inviteFids;
        nextViewController.ExistedIds = self.inviteFids;
        nextViewController.controller = self;
        nextViewController.eventId = _eventId;
    }

}




@end
