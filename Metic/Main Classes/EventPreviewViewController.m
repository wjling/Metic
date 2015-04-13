//
//  EventPreviewViewController.m
//  WeShare
//
//  Created by 俊健 on 15/4/13.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventPreviewViewController.h"
#import "EventCellTableViewCell.h"
#import "EventPhotosTableViewCell.h"
#import "Reachability.h"
#import "UIImageView+WebCache.h"

#define MainFontSize 14


@interface EventPreviewViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UIView* commentView;
@property(nonatomic,strong) UITextView* inputTextView;
@property(nonatomic,strong) NSArray* bestPhotos;
@property(nonatomic,strong) NSNumber* visibility;
@property(nonatomic,strong) NSNumber* eventId;
@property BOOL shouldShowPhoto;
@property BOOL isKeyBoard;

@end

@implementation EventPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedExt:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initUI
{
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self.navigationItem setTitle:@"活动详情"];
    if (!_tableView) {
        CGRect frame = self.view.frame;
        frame.size.height -= 64 - frame.origin.y;
        frame.origin.y = 0;
        _tableView = [[UITableView alloc]initWithFrame:frame];
        [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setRowHeight:289];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView reloadData];
    }
    if (_visibility && ![_visibility boolValue])
    {
        //此活动不允许陌生人参与
        [self setupBottomLabel:@"此活动不允许陌生人参与" textColor:[UIColor grayColor] offset:64];
    }else if(_visibility){
        [self setupApplyTextView];
    }
}

- (void)initData
{
    _isKeyBoard = NO;
    _eventId = [_eventInfo valueForKey:@"event_id"];
    _visibility = [_eventInfo valueForKey:@"visibility"];
    if (_visibility && [_visibility boolValue] && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        _shouldShowPhoto = YES;
    }else _shouldShowPhoto = NO;
    if (_shouldShowPhoto) {
        [self pullPhotos];
    }

}

- (void)pullPhotos
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:4] forKey:@"number"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_GOOD_PHOTOS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"good_photos"]];
                    for (int i = 0; i < newphoto_list.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list[i]];
                        newphoto_list[i] = dictionary;
                    }
                    //[self updateVideoInfoToDB:newvideo_list];
                    
                    _bestPhotos = newphoto_list;
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                    break;
                default:{
                }
            }
            
        }else{
        }
    }];
    
    
}

-(void)setupBottomLabel:(NSString*)content textColor:(UIColor*)color offset:(NSInteger)offset
{
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50 - offset, self.view.bounds.size.width, 50)];
    label.text = content;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor colorWithWhite:252.0/255.0 alpha:1.0];
    label.layer.borderColor = [UIColor colorWithWhite:220.0/255.0 alpha:1.0].CGColor;
    label.layer.borderWidth = 1;
}

-(void)setupApplyTextView
{
    //初始化评论框
    UIView *commentV = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 45 - 64, self.view.frame.size.width,45)];
    _commentView = commentV;
    [commentV setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [sendBtn setFrame:CGRectMake(250, 5, 65, 35)];
    [sendBtn setTitle:@"申请加入" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [sendBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85.0/255 green:203.0/255 blue:171.0/255 alpha:1.0f]] forState:UIControlStateNormal];
    sendBtn.layer.cornerRadius = 3;
    sendBtn.layer.masksToBounds = YES;
    [sendBtn addTarget:self action:@selector(apply:) forControlEvents:UIControlEventTouchUpInside];
    [commentV addSubview:sendBtn];
    
    [self.view addSubview:commentV];
    
    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    _inputTextView = textView;
    textView.font = [UIFont systemFontOfSize:16];
    textView.textColor = [UIColor colorWithWhite:80.0/255.0 alpha:1.0f];
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    if ([MTUser sharedInstance].name && ![[MTUser sharedInstance].name isEqual:[NSNull null]]) {
        textView.text = [NSString stringWithFormat:@"我是%@",[MTUser sharedInstance].name];
    }else textView.placeHolder = @"请输入申请理由";

    textView.delegate = self;
    
    [commentV addSubview:textView];
    
    textView.frame = CGRectMake(5, 5, 240, 35);
    textView.backgroundColor = [UIColor clearColor];
    textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    textView.layer.borderWidth = 0.65f;
    textView.layer.cornerRadius = 6.0f;

}

-(void)apply:(id)sender
{
    if (sender) {
        [sender setEnabled:NO];
    }
    NSString* confirmMsg = _inputTextView.text;
    NSDictionary* dictionary = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:995],@"cmd",[MTUser sharedInstance].userid,@"id",confirmMsg,@"confirm_msg", _eventId,@"event_id",nil];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        [sender setEnabled:YES];
        if (!rData) {
            return ;
        }
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                if (_isKeyBoard) {
                    [_inputTextView resignFirstResponder];
                }
                [_inputTextView removeFromSuperview];
                [self setupBottomLabel:@"已申请加入" textColor:[UIColor colorWithRed:85.0/255 green:203.0/255 blue:171.0/255 alpha:1.0f] offset:0];
                
            }
                break;
        }
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *eventCellIdentifier = @"eventcell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventCellTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:eventCellIdentifier];
            nibsRegistered = YES;
        }
        EventCellTableViewCell *cell = (EventCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
        //        NSLog(@"%@",_event);
        cell.eventName.text = [_eventInfo valueForKey:@"subject"];
        NSString* beginT = [_eventInfo valueForKey:@"time"];
        NSString* endT = [_eventInfo valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        if (endT.length > 9)cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        if (endT.length > 15)cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[_eventInfo valueForKey:@"launch_time"]];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[_eventInfo valueForKey:@"location"] ];
        NSInteger participator_count = [[_eventInfo valueForKey:@"member_count"] integerValue];
        NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
        NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
        
        cell.member_count.font = [UIFont systemFontOfSize:15];
        cell.member_count.numberOfLines = 0;
        cell.member_count.lineBreakMode = NSLineBreakByCharWrapping;
        cell.member_count.tintColor = [UIColor lightGrayColor];
        [cell.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
            NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
            UIFont *systemFont = [UIFont systemFontOfSize:18];
            
            if (redRange.location != NSNotFound) {
                // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:redRange];
                
                CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
                CFRelease(italicFont);
            }
            return mutableAttributedString;
        }];
        
        NSString* launcher = [[MTUser sharedInstance].alias_dic objectForKey:[NSString stringWithFormat:@"%@",[_eventInfo valueForKey:@"launcher_id"]]];
        if (launcher == nil || [launcher isEqual:[NSNull null]]) {
            launcher = [_eventInfo valueForKey:@"launcher"];
        }
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
        [cell.addPaticipator setBackgroundImage:[UIImage imageNamed:@"不能邀请好友"] forState:UIControlStateNormal];
        
        NSString* text = [_eventInfo valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:300.0 fontSize:MainFontSize isEmotion:YES];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
            commentHeight = 10;
        }else if(text) commentHeight += 5;
        cell.eventDetail.text = text;
        CGRect frame = cell.eventDetail.frame;
        frame.size.height = commentHeight;
        [cell.eventDetail setFrame:frame];
        frame = cell.frame;
        frame.size.height = 303 + commentHeight;
        cell.frame = frame;
        
        NSNumber* launcherId = [_eventInfo valueForKey:@"launcher_id"];
        PhotoGetter* authorImgGetter = [[PhotoGetter alloc]initWithData:cell.launcherImg authorId:launcherId];
        UIImageView* launcherImg = cell.launcherImg;
        launcherImg.layer.masksToBounds = YES;
        launcherImg.layer.cornerRadius = 4;
        [authorImgGetter getAvatar];
        cell.eventId = [_eventInfo valueForKey:@"event_id"];
        cell.eventController = self;
        [cell drawOfficialFlag:[[_eventInfo valueForKey:@"verify"] boolValue]];
        
        PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:self.eventId];
        NSString* bannerURL = [_eventInfo valueForKey:@"banner"];
        [bannerGetter getBanner:[_eventInfo valueForKey:@"code"] url:bannerURL];
        
        NSArray *memberids = [_eventInfo valueForKey:@"member"];
        for (int i =0; i<4; i++) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            if (i < participator_count) {
                PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [miniGetter getAvatar];
            }else tmp.image = nil;
            
        }
        [cell.videoWall setHidden:YES];
        [cell.imgWall setHidden:YES];
        [cell.videoWall_icon setHidden:YES];
        [cell.imgWall_icon setHidden:YES];
        return cell;
    }else{
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventPhotosTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:@"EventPhotosTableViewCell"];
            nibsRegistered = YES;
        }
        EventPhotosTableViewCell *cell = (EventPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EventPhotosTableViewCell"];
        if (_shouldShowPhoto) {
            cell.imagesView.hidden = NO;
            for (int i = 0; i < 4; i++) {
                UIImageView* imgView = cell.images[i];
                if (i < _bestPhotos.count) {
                    NSDictionary* photoInfo = _bestPhotos[i];
                    imgView.hidden = NO;
                    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[photoInfo valueForKey:@"photo_name"]]];
                    [imgView setContentMode:UIViewContentModeScaleAspectFit];
                    [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (!image) {
                            imgView.image = [UIImage imageNamed:@"加载失败"];
                        }else{
                            [imgView setContentMode:UIViewContentModeScaleAspectFill];
                        }
                    }];
                }else{
                    imgView.hidden = YES;
                }
            }
        }else{
            cell.imagesView.hidden = YES;
        }

        
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString* text = [_eventInfo valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:300.0 fontSize:MainFontSize isEmotion:NO];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
            commentHeight = 10;
        }else if(text) commentHeight += 5;
        return 262 + commentHeight;
    }
    else {
        if (_shouldShowPhoto && _bestPhotos.count > 0) return 131;
        else return 51;
    }

}

#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyBoard = NO;
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - TextView view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self apply:[_commentView viewWithTag:520]];
        return NO;
    }
    return YES;
}

-(void)textChangedExt:(NSNotification *)notification
{
    CGRect frame = _inputTextView.frame;
    float change = _inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && _inputTextView.contentSize.height < 90) {
        frame.size.height = _inputTextView.contentSize.height;
        [_inputTextView setFrame:frame];
        frame = _commentView.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [_commentView setFrame:frame];
    }
}

#pragma mark - Scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isKeyBoard) {
        [self.inputTextView resignFirstResponder];
    }
}

@end
