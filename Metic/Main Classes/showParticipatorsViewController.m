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
    _fids = [[NSMutableArray alloc]init];
    _participants = [[NSMutableArray alloc]init];
    //self.inviteFids = [[NSMutableSet alloc]initWithArray:self.fids];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self getEventParticipants];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return _visibility? _participants.count + 1:_participants.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"participatorCell" forIndexPath:indexPath];
    if(indexPath.row != _participants.count){
        NSDictionary* participant = _participants[indexPath.row];
        UIImageView* avatar = (UIImageView*)[cell viewWithTag:1];
        UILabel* name = (UILabel*)[cell viewWithTag:2];
        avatar.layer.masksToBounds = YES;
        [avatar.layer setCornerRadius:5];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[participant valueForKey:@"id"]];
        [getter getPhoto];
        name.text = [participant valueForKey:@"name"];

    }else{
        UIImageView* add = (UIImageView*)[cell viewWithTag:1];
        [add setImage:[UIImage imageNamed:@"添加参与者icon"]];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _participants.count) {
        [self performSegueWithIdentifier:@"inviteFriends" sender:self];
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
