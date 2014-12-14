//
//  EventDetail2.m
//  WeShare
//
//  Created by ligang6 on 14-11-13.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "EventDetail2.h"
#import "../Source/SDWebImage/UIButton+WebCache.h"
#import "../Source/SDWebImage/UIImageView+WebCache.h"
#import "../Utils/CommonUtils.h"
#import "../Source/MLEmoji/TTTAttributedLabel/TTTAttributedLabel.h"
#import "CircleCellTableViewCell.h"

#define bannerHeight 160

@interface EventDetail2 ()

@property (nonatomic,strong) UIView* flowInfoView;
@property (nonatomic,strong) UIScrollView* SscrollView;
@property (nonatomic,strong) UIScrollView* details;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UIView* indicator;

//活动详情元素
@property (nonatomic,strong) UILabel* author;
@property (nonatomic,strong) UILabel* publishTime;
@property (nonatomic,strong) UIButton* avatar;
@property (nonatomic,strong) UIButton* enshrine;
@property (nonatomic,strong) UIButton* share;
@property (nonatomic,strong) UIButton* favor;

@property BOOL nibsRegistered;
@property BOOL shouldPlay;


@end

@implementation EventDetail2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                            object:nil
                                                          userInfo:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    _nibsRegistered = NO;
    _loadingVideo = [[NSMutableSet alloc]init];
}

- (void)initUI
{
    [self.navigationItem setTitle:@"活动详情"];
    CGRect frame = self.navigationController.view.window.frame;
    frame.size.height -= 64.0f;
    
    //容器
    UIScrollView* SscrollView = [[UIScrollView alloc]initWithFrame:frame];
    _SscrollView = SscrollView;
    SscrollView.delegate = self;
    SscrollView.layer.borderWidth = 1;
    SscrollView.layer.borderColor = [UIColor yellowColor].CGColor;
    [SscrollView setContentSize:CGSizeMake(frame.size.width*2, frame.size.height)];
    SscrollView.pagingEnabled = YES;
    [self.view addSubview:SscrollView];

    
    
    
    UIView* flowInfoView = [[UIView alloc]initWithFrame:CGRectZero];
    _flowInfoView = flowInfoView;
    
    
    UIButton* banner = [UIButton buttonWithType:UIButtonTypeCustom];
    [banner setFrame:CGRectMake(0, 0, frame.size.width, frame.size.width/2)];
    [banner sd_setImageWithURL:nil forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
    [flowInfoView addSubview:banner];
    
    //官字号
    float width = banner.bounds.size.width;
    UIImageView* officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width*0.88, 0, width*0.072, width*0.1)];
    officialFlag.image = [UIImage imageNamed:@"detailed_label"];
    [banner addSubview:officialFlag];
    
    UIView* tabs = [[UIView alloc]initWithFrame:CGRectMake(0, banner.frame.size.height, frame.size.width, 35)];
    [tabs setBackgroundColor:[UIColor colorWithWhite:224.0f/255.0 alpha:1.0f]];
    [flowInfoView addSubview:tabs];
    
    UIButton* tab1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [tab1 setTitle:@"活动详情" forState:UIControlStateNormal];
    [tab1.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [tab1 setTitleColor:[UIColor colorWithWhite:68.0f/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [tab1 setFrame:CGRectMake(0, 0, frame.size.width/2-0.5, 30)];
    [tab1 setBackgroundColor:[UIColor whiteColor]];
    [tabs addSubview:tab1];
    
    UIButton* tab2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [tab2 setTitle:@"活动小圈" forState:UIControlStateNormal];
    [tab2.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [tab2 setTitleColor:[UIColor colorWithWhite:68.0f/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [tab2 setFrame:CGRectMake(frame.size.width/2+0.5, 0, frame.size.width/2-0.5, 30)];
    [tab2 setBackgroundColor:[UIColor whiteColor]];
    [tabs addSubview:tab2];
    
    UIView* indicator = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width/6, 27, frame.size.width/6, 3)];
    [indicator setBackgroundColor:[UIColor colorWithRed:240.0/255 green:114.0/255 blue:52.0/255 alpha:1.0f]];
    [tabs addSubview:indicator];
    _indicator = indicator;
    
    [flowInfoView setFrame:CGRectMake(0, 0, 320, CGRectGetMaxY(tabs.frame))];
    [self.view addSubview:flowInfoView];
    
    
    
    
    
    
    
    
    
    //活动详情
    UIScrollView* details = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    details.scrollEnabled = YES;
    details.delegate = self;
    _details = details;
    
    //发起者信息
    CGRect headFrame = CGRectMake(0, CGRectGetMaxY(_flowInfoView.frame), details.frame.size.width, 45);
    UIView* head = [[UIView alloc]initWithFrame:headFrame];
    head.layer.borderColor = [UIColor colorWithWhite:224.0f/255.0 alpha:1.0f].CGColor;
    head.layer.borderWidth = 0.5;
    [_details addSubview:head];
    
    //发起者头像
    _avatar = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatar.frame = CGRectMake(10, 7, 32, 32);
    [head addSubview:_avatar];
    [_avatar sd_setImageWithURL:nil forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
    
    //发起者头像蒙板
    UIImageView* shad = [[UIImageView alloc]initWithFrame: CGRectMake(10, 7, 32, 32)];
    shad.image = [UIImage imageNamed:@"头像-116（白色底）"];
    [head addSubview:shad];
    
    //发起者名称
    _author = [[UILabel alloc]initWithFrame:CGRectMake(5+CGRectGetMaxX(_avatar.frame), 8, 170, 18)];
    [head addSubview:_author];
    _author.text = @"我是海贼王哈哈哈哈哈哈";
    _author.font = [UIFont systemFontOfSize:13];
    _author.textColor = [UIColor colorWithWhite:68.0/255 alpha:1.0f];
    
    //发起时间
    _publishTime = [[UILabel alloc]initWithFrame:CGRectMake(5+CGRectGetMaxX(_avatar.frame), 26, 170, 12)];
    [head addSubview:_publishTime];
    _publishTime.text = @"两小时前发布";
    _publishTime.font = [UIFont systemFontOfSize:9];
    _publishTime.textColor = [UIColor colorWithWhite:147.0/255 alpha:1.0f];
    
    //收藏按钮
    _enshrine = [UIButton buttonWithType:UIButtonTypeCustom];
    _enshrine.frame = CGRectMake(frame.size.width - 32*3 - 15, 7, 32, 32);
    [head addSubview:_enshrine];
    [_enshrine setImage:[UIImage imageNamed:@"detailed_collect"] forState:UIControlStateNormal];

    //分享按钮
    _share = [UIButton buttonWithType:UIButtonTypeCustom];
    _share.frame = CGRectMake(frame.size.width - 32*2 - 15, 7, 32, 32);
    [head addSubview:_share];
    [_share setImage:[UIImage imageNamed:@"detailed_share"] forState:UIControlStateNormal];
    [_share setImage:[UIImage imageNamed:@"detailed_share_pressed"] forState:UIControlStateHighlighted];
    
    //点赞按钮
    _favor = [UIButton buttonWithType:UIButtonTypeCustom];
    _favor.frame = CGRectMake(frame.size.width - 32*1 - 15, 7, 32, 32);
    [head addSubview:_favor];
    [_favor setImage:[UIImage imageNamed:@"detailed_praise"] forState:UIControlStateNormal];
    [_favor setImage:[UIImage imageNamed:@"detailed_praise_pressed"] forState:UIControlStateHighlighted];
    
    //活动信息
    UIView* eventInfo = [[UIView alloc]initWithFrame:CGRectZero];
    
    //活动标题
    UILabel* eventTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    eventTitle.text = @"2014方大同Soulboy Lights Up世界巡回演唱会武汉站，标题最多45个字符......";
    eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    eventTitle.numberOfLines = 2;
    eventTitle.font = [UIFont systemFontOfSize:15];
    eventTitle.textColor = [UIColor colorWithWhite:68.0/255 alpha:1.0f];
    float titleHeight = [CommonUtils calculateTextHeight:eventTitle.text width:frame.size.width - 20 fontSize:15 isEmotion:NO];
    [eventTitle setFrame:CGRectMake(10, 0, frame.size.width - 20, titleHeight)];
    [eventInfo addSubview:eventTitle];
    
    //活动时间
    UIImageView* timeLogo = [[UIImageView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(eventTitle.frame)+3, 10, 10)];
    timeLogo.image = [UIImage imageNamed:@"detailed_time"];
    [eventInfo addSubview:timeLogo];
    UILabel* time = [[UILabel alloc]initWithFrame:CGRectMake(25, CGRectGetMaxY(eventTitle.frame), 280, 16)];
    time.text = @"2014年10月28日18:23-30日16:33";
    time.font = [UIFont systemFontOfSize:9];
    time.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
    [eventInfo addSubview:time];
    
    
    //活动地点
    UIImageView* positionLogo = [[UIImageView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(eventTitle.frame)+16, 10, 10)];
    positionLogo.image = [UIImage imageNamed:@"detailed_address"];
    [eventInfo addSubview:positionLogo];
    UILabel* position = [[UILabel alloc]initWithFrame:CGRectMake(25, CGRectGetMaxY(eventTitle.frame)+13, 280, 16)];
    position.text = @"天河区高普路软件园管委会";
    position.font = [UIFont systemFontOfSize:9];
    position.textColor = [UIColor colorWithWhite:147.0/255.0 alpha:1.0f];
    [eventInfo addSubview:position];
    
    [eventInfo setFrame:CGRectMake(0, CGRectGetMaxY(headFrame)+5, frame.size.width, CGRectGetMaxY(position.frame) + 10)];
    [_details addSubview:eventInfo];
    
    //活动描述
    NSString* text = @"冬日的天，带着些许凄凉往返于街道两旁，吹冷了谁孤寂的心？辗转现实与梦幻的边缘，倾听落雨的故事，繁花四季，开出了谁哭泣的美丽？风儿也在这感动中落下了泪，飘下了雨，牵手的回忆在谁的脑海翻腾出朵朵浪花？";
    text = [text stringByAppendingString:@"[查看更多]"];
    float descriptionHeight = [CommonUtils calculateTextHeight:text width:frame.size.width -30 fontSize:12 isEmotion:NO];
    UIView* descriptionContainer = [[UIView alloc]initWithFrame:CGRectMake(10.0, CGRectGetMaxY(eventInfo.frame), frame.size.width - 20, descriptionHeight+5)];
    [descriptionContainer setBackgroundColor:[UIColor colorWithWhite:238.0/255.0f alpha:1.0f]];
    
    TTTAttributedLabel *description = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, descriptionContainer.frame.size.width - 10, descriptionContainer.frame.size.height)];
    [description setNumberOfLines:0];
    [description setFont:[UIFont systemFontOfSize:18.0f]];
    [description setTextAlignment:NSTextAlignmentLeft];
    [description setLineBreakMode:NSLineBreakByWordWrapping];
    NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc] initWithString:text];
    [hintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:48.0/255.0f green:122.0/255.0f blue:173/255.0f alpha:1.0f] CGColor] range:NSMakeRange(text.length-6,6)];
    [hintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithWhite:105.0f/255.0 alpha:1.0f] CGColor] range:NSMakeRange(0,text.length-6)];
    [hintString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:12.0] range:NSMakeRange(0, text.length)];
    [description setText:hintString];
    [descriptionContainer addSubview:description];
    [_details addSubview:descriptionContainer];
    
    //活动参与者
    UIView *participatorsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(descriptionContainer.frame)+10, frame.size.width, 30)];
    participatorsView.layer.borderWidth = 0.5;
    participatorsView.layer.borderColor = [UIColor colorWithWhite:224.0f/255.0 alpha:1.0f].CGColor;
    [_details addSubview:participatorsView];
    
    //参与者头像
    int num = 4;
    for (int i = 0; i < num; i++) {
        UIImageView* Pavatar = [[UIImageView alloc]initWithFrame:CGRectMake(10 + 30*i, 5, 20, 20)];
        [Pavatar sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
        [participatorsView addSubview:Pavatar];
        UIImageView* Pshad = [[UIImageView alloc]initWithFrame:Pavatar.frame];
        Pshad.image = [UIImage imageNamed:@"头像-116（白色底）"];
        [participatorsView addSubview:Pshad];
    }
    
    //参与者数目
    int pnum = 100;
    NSNumber* pNum = [NSNumber numberWithInt:pnum];
    UIImageView* pnumJump = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(participatorsView.frame) - 25, 6, 15, 18)];
    pnumJump.image = [UIImage imageNamed:@"detailed_return"];
    [participatorsView addSubview:pnumJump];
    
    TTTAttributedLabel *participtorLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(participatorsView.frame) - 150, 3.0f, 120, 24)];
    [participtorLabel setNumberOfLines:0];
    [participtorLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [participtorLabel setTextAlignment:NSTextAlignmentRight];
    [participtorLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSString* pText = [NSString stringWithFormat:@"已有%@人参加",pNum];
    NSMutableAttributedString *phintString = [[NSMutableAttributedString alloc] initWithString:pText];
    
    [phintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:240.0/255.0f green:114.0/255.0f blue:52.0/255.0f alpha:1.0f] CGColor] range:NSMakeRange(2,pText.length - 5)];
    [phintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithWhite:149.0f/255.0 alpha:1.0f] CGColor] range:NSMakeRange(pText.length-3,3)];
    [phintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithWhite:149.0f/255.0 alpha:1.0f] CGColor] range:NSMakeRange(0,2)];
    [phintString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0] range:NSMakeRange(0, pText.length)];
    [participtorLabel setText:phintString];
    [participatorsView addSubview:participtorLabel];
    
    //小工具
    UIView* toolsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(participatorsView.frame)-0.5, frame.size.width, 90)];
    toolsView.layer.borderColor = [UIColor colorWithWhite:224.0f/255.0 alpha:1.0f].CGColor;
    toolsView.layer.borderWidth = 0.5;
    [_details addSubview:toolsView];
    
    NSArray*labelText = @[@"活动公告",@"活动事项",@"任务列表"];
    NSArray* buttonIcon = @[[UIImage imageNamed:@"detailed_announcement_icon"],[UIImage imageNamed:@"detailed_item_icon"],[UIImage imageNamed:@"detailed_item_task_icon"]];
    
    for (int i = 0; i < 3; i++) {
        UIButton* tool = [UIButton buttonWithType:UIButtonTypeCustom];
        [tool setFrame:CGRectMake(45 + i*90, 10, 50, 50)];
        [tool setImage:buttonIcon[i] forState:UIControlStateNormal];
        [toolsView addSubview:tool];
        
        UILabel* tLabel = [[UILabel alloc]initWithFrame:CGRectMake(45 + i*90, 63, 50, 20)];
        tLabel.text = labelText[i];
        tLabel.font = [UIFont systemFontOfSize:11];
        tLabel.textAlignment = NSTextAlignmentCenter;
        tLabel.textColor = [UIColor colorWithWhite:68.0/255 alpha:1.0f];
        [toolsView addSubview:tLabel];
    }
    
    //活动类型
    UIView* eventType = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(toolsView.frame), frame.size.width, 105)];
    [_details addSubview:eventType];
    
    UILabel* eventTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 30)];
    eventTypeLabel.text = @"活动类型";
    eventTypeLabel.textColor = [UIColor colorWithWhite:68.0/255 alpha:1.0f];
    eventTypeLabel.textAlignment = NSTextAlignmentLeft;
    eventTypeLabel.font = [UIFont systemFontOfSize:14];
    [eventType addSubview:eventTypeLabel];
    
    int Tnum = 10;
    for (int i = 0; i < Tnum; i++) {
        UIButton* typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [typeButton setFrame:CGRectMake(10 + (i%4)*80, 30 + (i/4)*40, 60, 25)];
//        typeButton.layer.borderColor = [UIColor redColor].CGColor;
//        typeButton.layer.borderWidth = 2;
        typeButton.layer.cornerRadius = 12;
        typeButton.layer.masksToBounds = YES;
        typeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [typeButton setTitle:@"生活" forState:UIControlStateNormal];
        [typeButton setTitleColor:[UIColor colorWithWhite:105.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        [typeButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xeeeeee]] forState:UIControlStateNormal];
        [typeButton setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xf8f8f8]] forState:UIControlStateHighlighted];
        [eventType addSubview:typeButton];
        if (i == Tnum - 1) {
            [eventType setFrame:CGRectMake(0, CGRectGetMaxY(toolsView.frame), frame.size.width, CGRectGetMaxY(typeButton.frame)+10)];
        }
    }
    details.contentSize = CGSizeMake(frame.size.width, CGRectGetMaxY(eventType.frame));
    [_SscrollView addSubview:details];

    
    //活动小圈
    UITableView* tableView = [[UITableView alloc]initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
    tableView.bounces = YES;
    tableView.scrollEnabled = YES;
    tableView.layer.borderWidth = 2;
    tableView.layer.borderColor = [UIColor redColor].CGColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [_SscrollView addSubview:_tableView];
    
    
    
    
    
    
    
    
    
}

#pragma mark 代理方法-UITableView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _SscrollView) {
        CGRect frame = _indicator.frame;
        frame.origin.x = self.navigationController.view.window.frame.size.width/6 + scrollView.contentOffset.x/2;
        _indicator.frame = frame;
    }
    
    if (scrollView == _details) {
        if (scrollView.contentOffset.y <= bannerHeight) {
            CGRect frame = _flowInfoView.frame;
            frame.origin.y = scrollView.contentOffset.y * -1;
            _flowInfoView.frame = frame;
        }else{
            CGRect frame = _flowInfoView.frame;
            if (frame.origin.y != bannerHeight*-1) {
                frame.origin.y = bannerHeight * -1;
                _flowInfoView.frame = frame;
            }
            
        }
    }
    
    if (scrollView == _tableView) {
        _shouldPlay = NO;
        if (scrollView.contentOffset.y <= bannerHeight) {
            CGRect frame = _flowInfoView.frame;
            frame.origin.y = scrollView.contentOffset.y * -1;
            _flowInfoView.frame = frame;
        }else{
            CGRect frame = _flowInfoView.frame;
            if (frame.origin.y != bannerHeight*-1) {
                frame.origin.y = bannerHeight * -1;
                _flowInfoView.frame = frame;
            }
            
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if (scrollView == _SscrollView) {
//        if (_SscrollView.contentOffset.x == _SscrollView.frame.size.width) {
//            
//            _tableView.frame = CGRectMake(_SscrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
//            if (_scrollView.contentOffset.y >= CGRectGetMinY(_SscrollView.frame)) _scrollView.contentOffset = CGPointMake(0, CGRectGetMinY(_SscrollView.frame));
//            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_tableView.frame) + CGRectGetMinY(_SscrollView.frame));
//        }
//        if (_SscrollView.contentOffset.x == 0) {
//            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_details.frame) + CGRectGetMinY(_SscrollView.frame));
//        }
//    }
    
    if (scrollView == _tableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                            object:nil
                                                          userInfo:nil];
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        _shouldPlay = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_shouldPlay == YES) {
                _shouldPlay = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"initLVideo"
                                                                    object:nil
                                                                  userInfo:nil];
                
            }
            
        });
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _details) {
        CGPoint point = _tableView.contentOffset;
        if (point.y != 0) {
            _tableView.contentOffset = CGPointMake(0, 0);
        }
    }
    
    if (scrollView == _tableView) {
        CGPoint point = _details.contentOffset;
        if (point.y != 0) {
            _details.contentOffset = CGPointMake(0, 0);
        }
    }
    
    if (scrollView == _SscrollView) {
        if (scrollView.contentOffset.x == 0) {
            NSLog(@"left");
            _tableView.contentOffset = CGPointMake(0, _flowInfoView.frame.origin.y * -1);
        }
        
        if (scrollView.contentOffset.x == self.view.frame.size.width) {
            NSLog(@"right");
            _details.contentOffset = CGPointMake(0, _flowInfoView.frame.origin.y * -1);
        }
    }
}

#pragma mark 代理方法-UIScrollView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return _flowInfoView.frame.size.height;
    }
    switch (indexPath.row % 3) {
        case 0:
            return 150;
            break;
        case 1:
            return 400;
            break;
        case 2:
            return 400;
            break;
            
        default:
            return 150;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell* cell = [[UITableViewCell alloc]init];
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
    NSString* circleCellIdentifier = @"CircleCellTableViewCell";
    if (!_nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([CircleCellTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:circleCellIdentifier];
        _nibsRegistered = YES;
    }
    CircleCellTableViewCell *cell = (CircleCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:circleCellIdentifier];
    cell.type = indexPath.row % 3;
    cell.controller = self;
    [cell drawCell];
    return cell;
}


@end
