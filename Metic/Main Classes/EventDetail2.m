//
//  EventDetail2.m
//  WeShare
//
//  Created by ligang6 on 14-11-13.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "EventDetail2.h"
#import "../Source/SDWebImage/UIButton+WebCache.h"
#import "../Utils/CommonUtils.h"
#import "../Source/MLEmoji/TTTAttributedLabel/TTTAttributedLabel.h"

@interface EventDetail2 ()

@property (nonatomic,strong) UIScrollView* scrollView;
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


@end

@implementation EventDetail2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [self.navigationItem setTitle:@"活动详情"];
    
    CGRect frame = self.navigationController.view.window.frame;
    NSLog(@"%f  %f",frame.size.width,frame.size.height);
    frame.size.height -= 64.0f;
    _scrollView = [[UIScrollView alloc]initWithFrame:frame];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    UIButton* banner = [UIButton buttonWithType:UIButtonTypeCustom];
    [banner setFrame:CGRectMake(0, 0, frame.size.width, frame.size.width/2)];
    [banner sd_setImageWithURL:nil forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"1星空.jpg"]];
    [_scrollView addSubview:banner];
    
    //官字号
    float width = banner.bounds.size.width;
    UIImageView* officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width*0.88, 0, width*0.072, width*0.1)];
    officialFlag.image = [UIImage imageNamed:@"detailed_label"];
    [banner addSubview:officialFlag];
    
    UIView* tabs = [[UIView alloc]initWithFrame:CGRectMake(0, banner.frame.size.height, frame.size.width, 35)];
    [tabs setBackgroundColor:[UIColor colorWithWhite:224.0f/255.0 alpha:1.0f]];
    [_scrollView addSubview:tabs];
    
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
    
    //活动详情
    UIScrollView* details = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    details.scrollEnabled = NO;
    details.delegate = self;
    _details = details;
    
    //发起者信息
    CGRect headFrame = CGRectMake(0, 0, details.frame.size.width, 45);
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
    _enshrine.frame = CGRectMake(frame.size.width - 32*3 - 5, 7, 32, 32);
    [head addSubview:_enshrine];
    [_enshrine setImage:[UIImage imageNamed:@"detailed_collect"] forState:UIControlStateNormal];

    //分享按钮
    _share = [UIButton buttonWithType:UIButtonTypeCustom];
    _share.frame = CGRectMake(frame.size.width - 32*2 - 5, 7, 32, 32);
    [head addSubview:_share];
    [_share setImage:[UIImage imageNamed:@"detailed_share"] forState:UIControlStateNormal];
    [_share setImage:[UIImage imageNamed:@"detailed_share_pressed"] forState:UIControlStateHighlighted];
    
    //点赞按钮
    _favor = [UIButton buttonWithType:UIButtonTypeCustom];
    _favor.frame = CGRectMake(frame.size.width - 32*1 - 5, 7, 32, 32);
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
    float descriptionHeight = [CommonUtils calculateTextHeight:text width:frame.size.width -30 fontSize:13 isEmotion:NO];
    UIView* descriptionContainer = [[UIView alloc]initWithFrame:CGRectMake(10.0, CGRectGetMaxY(eventInfo.frame), frame.size.width - 20, descriptionHeight)];
    [descriptionContainer setBackgroundColor:[UIColor colorWithWhite:238.0/255.0f alpha:1.0f]];
    
    TTTAttributedLabel *description = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, descriptionContainer.frame.size.width - 10, descriptionContainer.frame.size.height - 10)];
    [description setNumberOfLines:0];
    [description setFont:[UIFont systemFontOfSize:13.0f]];
    [description setTextColor:[UIColor colorWithWhite:105.0f/255.0 alpha:1.0f]];
    [description setTextAlignment:NSTextAlignmentLeft];
    [description setLineBreakMode:NSLineBreakByWordWrapping];
    NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc] initWithString:text];
    [hintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRed:48.0/255.0f green:122.0/255.0f blue:173/255.0f alpha:1.0f] CGColor] range:NSMakeRange(text.length-6,6)];
    [hintString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithWhite:105.0f/255.0 alpha:1.0f] CGColor] range:NSMakeRange(0,text.length-6)];
    [description setText:hintString];
    [descriptionContainer addSubview:description];
    [_details addSubview:descriptionContainer];
    
    
    
    
    
    
    
    
    
    
    details.contentSize = CGSizeMake(frame.size.width, 1000);
    
    
    
    
    
    //活动小圈
    UITableView* tableView = [[UITableView alloc]initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
    tableView.scrollEnabled = NO;
    tableView.layer.borderWidth = 2;
    tableView.layer.borderColor = [UIColor redColor].CGColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    
    
    float height = details.frame.size.height;
    if (tableView.frame.size.height > height) height = tableView.frame.size.height;
    
    //容器
    CGRect Sframe = frame;
    Sframe.origin.y = CGRectGetMaxY(tabs.frame);
    Sframe.size.height = height;
    NSLog(@"%f",Sframe.origin.y);
    UIScrollView* SscrollView = [[UIScrollView alloc]initWithFrame:Sframe];
    _SscrollView = SscrollView;
    SscrollView.delegate = self;
//    SscrollView.layer.borderWidth = 1;
//    SscrollView.layer.borderColor = [UIColor yellowColor].CGColor;
    [SscrollView setContentSize:CGSizeMake(Sframe.size.width*2, Sframe.size.height)];
    SscrollView.pagingEnabled = YES;
    
    [SscrollView addSubview:details];
    [SscrollView addSubview:tableView];
    
    [_scrollView addSubview:SscrollView];
    
    [_scrollView setContentSize:CGSizeMake(frame.size.width, CGRectGetMaxY(SscrollView.frame))];
}

#pragma mark 代理方法-UITableView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _SscrollView) {
        CGRect frame = _indicator.frame;
        frame.origin.x = self.navigationController.view.window.frame.size.width/6 + scrollView.contentOffset.x/2;
        _indicator.frame = frame;
    }
    
    if (scrollView == _scrollView) {
        if (_scrollView.contentOffset.y >= CGRectGetMinY(_SscrollView.frame)) {
            if (!_tableView.isScrollEnabled) {
                _tableView.scrollEnabled = YES;
            }
            if (!_details.isScrollEnabled) {
                _details.scrollEnabled = YES;
            }
            
        }else if(_scrollView.contentOffset.y < CGRectGetMinY(_SscrollView.frame)) {
            if (_tableView.isScrollEnabled) {
                _tableView.scrollEnabled = NO;
            }
            if (_details.isScrollEnabled) {
                _details.scrollEnabled = NO;
            }
            
        }
    }
    
    if (scrollView == _tableView){
        if (_tableView.contentOffset.y <= 0 && _tableView.isScrollEnabled) {
            _tableView.scrollEnabled = NO;
        }else if(_tableView.contentOffset.y >= CGRectGetMinY(_SscrollView.frame) && !_tableView.isScrollEnabled){
            _tableView.scrollEnabled = YES;
        }
    }
    
    if (scrollView == _details){
        if (_details.contentOffset.y <= 0 && _details.isScrollEnabled) {
            _details.scrollEnabled = NO;
        }else if(_details.contentOffset.y >= CGRectGetMinY(_SscrollView.frame) && !_details.isScrollEnabled){
            _details.scrollEnabled = YES;
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
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc]init];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 80)];
    [label setBackgroundColor:[UIColor redColor]];
    [cell addSubview:label];
    return cell;
}
@end
