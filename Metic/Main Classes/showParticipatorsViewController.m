//
//  showParticipatorsViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-7-18.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "showParticipatorsViewController.h"
#import "InviteFriendViewController.h"
#import "PhotoGetter.h"
#import "UserInfo/UserInfoViewController.h"
#import "FriendInfoViewController.h"
#import "AvatarCollectionViewCell.h"

@interface showParticipatorsViewController ()
@property (nonatomic,strong) NSMutableSet *inviteFids;
@property (nonatomic,strong) NSMutableArray* participants;
@property (nonatomic,strong) NSNumber* kickingId;
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
    [_manage_Button setHidden:YES];
    _isManaging = NO;
    _isRemoving = NO;
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
    [super viewWillAppear:animated];
    if (!_canManage) {
        _isManaging = NO;
        _isRemoving = NO;
    }
    
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
//显示好友详情
- (void)pushToFriendView:(NSNumber*)fid {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
    if ([fid intValue] == [[MTUser sharedInstance].userid intValue]) {
        UserInfoViewController* userInfoView = [mainStoryboard instantiateViewControllerWithIdentifier: @"UserInfoViewController"];
        userInfoView.needPopBack = YES;
        [self.navigationController pushViewController:userInfoView animated:YES];
        
    }else{
        FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
        friendView.fid = fid;
        [self.navigationController pushViewController:friendView animated:YES];
    }
	
}


- (IBAction)manage:(id)sender {
    if (!_isManaging) {
        _isManaging = YES;
        [self.manage_Button setTitle:@"       完成" forState:UIControlStateNormal];
        _isRemoving = NO;
    }else{
        _isManaging = NO;
        [self.manage_Button setTitle:@"       管理" forState:UIControlStateNormal];
    }
    [self.collectionView reloadData];
}

-(void)getEventParticipants
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:_eventId forKey:@"event_id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_EVENT_PARTICIPANTS];
}

#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
        {
            if(_canManage) {
                _isManaging = YES;
            }else {
                _isManaging = NO;
            }
            [_participants removeAllObjects];
            [_participants addObjectsFromArray:(NSArray*)[response1 valueForKey:@"participant"]];
            [_fids removeAllObjects];
            for (int i = 0; i < _participants.count; i++) {
                NSDictionary* participant = [_participants objectAtIndex:i];
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
    
    AvatarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"participatorCell" forIndexPath:indexPath];
    NSInteger addition = 0;
    if(_isManaging){
        if (_isMine) {
            addition = 2;
            if (indexPath.row == 0) {
                UIImageView* add = cell.avatar;
                [add setImage:[UIImage imageNamed:@"添加图标"]];
                UILabel* name = cell.name;
                name.text = @"";
                [cell.deleteIcon setHidden:YES];//delete icon
                [cell.mask setHidden:YES];//mask
                return cell;
            }
            if (indexPath.row == 1) {
                UIImageView* add = cell.avatar;
                [add setImage:[UIImage imageNamed:@"删除图标"]];
                UILabel* name = cell.name;
                name.text = @"";
                [cell.deleteIcon setHidden:YES];//delete icon
                [cell.mask setHidden:YES];//mask
                return cell;
            }
        }else if (_visibility){
            addition = 1;
            if (indexPath.row == 0) {
                UIImageView* add = cell.avatar;
                [add setImage:[UIImage imageNamed:@"添加图标"]];
                UILabel* name = cell.name;
                name.text = @"";
                [cell.deleteIcon setHidden:YES];//delete icon
                [cell.mask setHidden:YES];//mask
                return cell;
            }
        }
    }
    
    NSDictionary* participant = _participants[indexPath.row - addition];
    UIImageView* avatar = cell.avatar;
    UILabel* name = cell.name;
    avatar.image = nil;
    PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[participant valueForKey:@"id"]];
    [getter getAvatar];
    //显示备注名
    NSString* alias = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[participant valueForKey:@"id"]]];
    if (alias == nil || [alias isEqual:[NSNull null]] || [alias isEqualToString:@""]) {
        alias = [participant valueForKey:@"name"];
    }
    name.text = alias;
    [cell.mask setHidden:NO];
    BOOL isMe = ([[participant valueForKey:@"id"] intValue] == [[MTUser sharedInstance].userid intValue]);
    if (_isRemoving && !isMe) {
        [cell.deleteIcon setHidden:NO];
    }else [cell.deleteIcon setHidden:YES];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger addition = 0;
    if(_isManaging){
        if (_isMine) {
            addition = 2;
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"inviteFriends" sender:self];
                return;
            }
            if (indexPath.row == 1) {
                self.isRemoving = !_isRemoving;
                [self.collectionView reloadData];
                return;
            }
        }else if (_visibility){
            addition = 1;
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"inviteFriends" sender:self];
                return;
            }
        }
    }
    
    NSDictionary* participant = _participants[indexPath.row - addition];
    BOOL isMe = ([[participant valueForKey:@"id"] intValue] == [[MTUser sharedInstance].userid intValue]);
    
    
    if (_isRemoving) {
        if (!isMe) {
            NSString* message = [NSString stringWithFormat:@"确定要将用户 %@ 请出此活动？",[participant valueForKey:@"name"]];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            [alert setTag:1];
            _kickingId = [participant valueForKey:@"id"];
        }
    }else{
        [self pushToFriendView:[participant valueForKey:@"id"]];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
                [dictionary setValue:_eventId forKey:@"event_id"];
                [dictionary setValue:[NSString stringWithFormat:@"[%@]",_kickingId] forKey:@"participant"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                MTLOG(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendMessage:jsonData withOperationCode:KICK_OUT finshedBlock:^(NSData *rData) {
                    if (rData) {
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        MTLOG(@"received Data: %@",response1);
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                UIAlertView* alert = [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"移除成功" WithDelegate:self WithCancelTitle:@"确定"];
                                [alert setTag:2];
                            }
                                break;
                            default:
                            {
                                [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"网络异常，移除失败" WithDelegate:nil WithCancelTitle:@"确定"];
                            }
                        }
                    }
                    else [CommonUtils showSimpleAlertViewWithTitle:@"系统消息" WithMessage:@"网络异常，移除失败" WithDelegate:nil WithCancelTitle:@"确定"];
                }];
            }
        }
            break;
            
        case 2:
        {
            [self getEventParticipants];
        }
            break;
        default:
            break;
    }
}




@end
