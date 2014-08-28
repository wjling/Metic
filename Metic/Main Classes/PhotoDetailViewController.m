//
//  PhotoDetailViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoDisplayViewController.h"
#import "BannerViewController.h"
#import "../Cell/PcommentTableViewCell.h"
#import "HomeViewController.h"
#import "../Utils/CommonUtils.h"
#import "MobClick.h"
#import "MLEmojiLabel.h"
#import "../Custom Wedgets/emotion_Keyboard.h"

@interface PhotoDetailViewController ()
@property (nonatomic,strong)NSNumber* sequence;
@property (nonatomic,strong)UIButton * delete_button;
@property (strong, nonatomic) IBOutlet UIButton *good_button;
@property (strong, nonatomic) IBOutlet UIButton *download_button;
@property float specificationHeight;
@property (nonatomic,strong) NSMutableArray * pcomment_list;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet emotion_Keyboard *emotionKeyboard;
@property (nonatomic,strong) NSNumber* repliedId;
@property (nonatomic,strong) NSString* herName;
@property BOOL isKeyBoard;
@property BOOL Footeropen;
@property long Selete_section;

@end

@implementation PhotoDetailViewController

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
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self initUI];
    self.sequence = [NSNumber numberWithInt:0];
    self.isKeyBoard = NO;
    self.Footeropen = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _emotionKeyboard.textView = _inputTextView;
    self.pcomment_list = [[NSMutableArray alloc]init];
    //[self initButtons];
    [self setGoodButton];
    //初始化上拉加载更多
    _footer = [[MJRefreshFooterView alloc]init];
    _footer.delegate = self;
    _footer.scrollView = _tableView;
    
    

    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputTextView resignFirstResponder];
    [MobClick beginLogPageView:@"图片主页"];
    self.sequence = [NSNumber numberWithInt:0];
    [self pullMainCommentFromAir];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"图片主页"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

-(void) initButtons
{
    for (UIButton* button in self.buttons) {
        UIImage *colorImage = [CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0] ];
        [button setBackgroundImage:colorImage forState:UIControlStateHighlighted];
        [button resignFirstResponder];
    }
    
}


-(void)initUI
{
    // 初始化输入框
    MTMessageTextView *textView = [[MTMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    [self.commentView addSubview:textView];
	_inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(38, 5, 240, 35);
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    
    [_emotionKeyboard initCollectionView];
}


- (IBAction)button_Emotionpress:(id)sender {
    if (!_emotionKeyboard) {
        _emotionKeyboard = [[emotion_Keyboard alloc]initWithPoint:CGPointMake(0, self.view.frame.size.height - 200)];
        
        
        
    }
    if (!_isEmotionOpen) {
        _isEmotionOpen = YES;
        if (_isKeyBoard) {
            [_inputTextView resignFirstResponder];
        }
        //[self.view bringSubviewToFront:_emotionKeyboard];
        //[self.view addSubview:_emotionKeyboard];
        CGRect keyboardBounds = _emotionKeyboard.frame;
        // get a rect for the textView frame
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        [_emotionKeyboard setFrame:frame];
        
        // commit animations
        [UIView commitAnimations];
    }else {
        _isEmotionOpen = NO;
        CGRect containerFrame = self.commentView.frame;
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        self.commentView.frame = containerFrame;
        CGRect frame = _emotionKeyboard.frame;
        frame.origin.y = self.view.frame.size.height;
        [_emotionKeyboard setFrame:frame];
        [UIView commitAnimations];
        //[_emotionKeyboard removeFromSuperview];
    }
    
    
}


-(void) setGoodButton
{
    if ([[self.photoInfo valueForKey:@"isZan"] boolValue]) {
        [self.buttons[0] setImage:[UIImage imageNamed:@"图片评论_点赞图标"] forState:UIControlStateNormal];
    }else [self.buttons[0] setImage:[UIImage imageNamed:@"图片评论_已赞"] forState:UIControlStateNormal];
}


-(float)calculateTextHeight:(NSString*)text width:(float)width fontSize:(float)fsize
{
    UIFont *font = [UIFont systemFontOfSize:fsize];
    CGSize size = CGSizeMake(width,2000);
    CGRect labelRect = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
    return ceil(labelRect.size.height)*1.25;
}

- (void)pullMainCommentFromAir
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.sequence forKey:@"sequence"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    NSLog(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_PCOMMENTS];
}


- (IBAction)good:(id)sender {
    [self.good_button setEnabled:NO];
    BOOL iszan = [[self.photoInfo valueForKey:@"isZan"] boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:[NSNumber numberWithInt:iszan? 2:3]  forKey:@"operation"];
    [dictionary setValue:@"good"  forKey:@"item_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD];
}

- (IBAction)comment:(id)sender {
    //[self.commentView setHidden:NO];
    //[self.view bringSubviewToFront:self.commentView];
    self.inputTextView.placeHolder = @"说点什么吧";
    [self.inputTextView becomeFirstResponder];
}

- (IBAction)share:(id)sender {
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"53bb542e56240ba6e80a4bfb"
                                      shareText:@"WeShare"
                                     shareImage:self.photo
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,nil]
                                       delegate:self];
}

- (IBAction)download:(id)sender {
    [self.download_button setEnabled:NO];
    UIImageWriteToSavedPhotosAlbum(self.photo,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    //UIImageWriteToSavedPhotosAlbum(self.photo, self, @selector(downloadComplete),nil);
}

-(void)deletePhoto:(UIButton*)button
{
    [button setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (button) {
            [button setEnabled:YES];
        }
    });
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除这张照片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

-(void)resendComment:(id)sender
{
    
    id cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]] ) {
        cell = [cell superview];
    }
    NSString *comment = ((PcommentTableViewCell*)cell).comment.text;
    int row = [_tableView indexPathForCell:cell].row;
    NSMutableDictionary *waitingComment = _pcomment_list[row-1];
    [waitingComment setValue:[NSNumber numberWithInt:-1] forKey:@"pcomment_id"];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    
    
    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(waitingComment && [[waitingComment valueForKey:@"pcomment_id"] intValue]== -1){
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            [_tableView reloadData];
            
        }
    });
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_PCOMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"pcomment_id"]) {
                {
                    [waitingComment setValue:[response1 valueForKey:@"pcomment_id"] forKey:@"pcomment_id"];
                    [waitingComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                    [_pcomment_list removeObject:waitingComment];
                    [_pcomment_list insertObject:waitingComment atIndex:0];
                    [_tableView reloadData];
                }
            }else{
                [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                [_tableView reloadData];
            }
        }else{
            [waitingComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            [_tableView reloadData];
        }
    }];
}


- (IBAction)publishComment:(id)sender {
    NSString *comment = self.inputTextView.text;
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        self.inputTextView.text = @"";
        return;
    }
    [self.inputTextView resignFirstResponder];
    if (_isEmotionOpen) [self button_Emotionpress:nil];
    self.inputTextView.text = @"";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self textViewDidChange:nil];
        self.inputTextView.text = @"";
    });
    NSLog(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if (_repliedId && [_repliedId intValue]!=[[MTUser sharedInstance].userid intValue]){
        [dictionary setValue:_repliedId forKey:@"replied"];
        comment = [[NSString stringWithFormat:@" 回复 %@ : ",_herName] stringByAppendingString:comment];
    }
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString*time = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableDictionary* newComment = [[NSMutableDictionary alloc]init];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"good"];
    [newComment setValue:_photoId forKey:@"photo_id"];
    [newComment setValue:[MTUser sharedInstance].name forKey:@"author"];
    [newComment setValue:[NSNumber numberWithInt:-1] forKey:@"pcomment_id"];
    [newComment setValue:comment forKey:@"content"];
    [newComment setValue:time forKey:@"time"];
    [newComment setValue:[MTUser sharedInstance].userid forKey:@"author_id"];
    [newComment setValue:[NSNumber numberWithInt:0] forKey:@"isZan"];

    if ([_pcomment_list isKindOfClass:[NSArray class]]) {
        _pcomment_list = [[NSMutableArray alloc]initWithArray:_pcomment_list];
    }
    [_pcomment_list insertObject:newComment atIndex:0];

    [_tableView reloadData];
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(newComment && [[newComment valueForKey:@"pcomment_id"] intValue]== -1){
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            [_tableView reloadData];
            
        }
    });

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_PCOMMENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY && [response1 valueForKey:@"pcomment_id"]) {
                {
                    [newComment setValue:[response1 valueForKey:@"pcomment_id"] forKey:@"pcomment_id"];
                    [newComment setValue:[response1 valueForKey:@"time"] forKey:@"time"];
                    [_pcomment_list removeObject:newComment];
                    [_pcomment_list insertObject:newComment atIndex:0];
                    [_tableView reloadData];
                }
            }else{
                [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
                [_tableView reloadData];
            }
        }else{
            [newComment setValue:[NSNumber numberWithInt:-2] forKey:@"pcomment_id"];
            [_tableView reloadData];
        }

    }];
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    [self.download_button setEnabled:YES];
    if (error){
        // Do anything needed to handle the error or display it to the user
    }else{
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"保存成功" WithDelegate:self WithCancelTitle:@"确定"];
    }
}

-(void)backToDisplay
{
    if (_isKeyBoard) {
        [self.inputTextView resignFirstResponder];
    }else {
        switch (self.type) {
            case 1:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 2:{
                BannerViewController* bannerView = [[BannerViewController alloc] init];
                bannerView.banner = self.photo;
                [self presentViewController:bannerView animated:YES completion:^{}];
            }
                break;
            default:
                break;
        }
    }
}

-(void)closeRJ
{
//    if (_Headeropen) {
//        _Headeropen = NO;
//        [_header endRefreshing];
//    }
    if (_Footeropen) {
        _Footeropen = NO;
        [_footer endRefreshing];
    }
    [self.tableView reloadData];
}

- (void)deletePhotoInfoFromDB
{
    NSString * path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    MySqlite *sql = [[MySqlite alloc]init];
    [sql openMyDB:path];
    NSDictionary *wheres = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",_photoId],@"photo_id", nil];
    [sql deleteTurpleFromTable:@"eventPhotos" withWhere:wheres];
    [sql closeMyDB];
}


//#pragma mark - UIScrollViewDelegate
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (!_isKeyBoard) {
//        [self.commentView setHidden:YES];
//        //[self.view sendSubviewToBack:self.commentView];
//    }
//}



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
            if ([response1 valueForKey:@"pcomment_list"]) {
                NSMutableArray *newComments = [[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"pcomment_list"]];
                [self.pcomment_list addObjectsFromArray:newComments] ;
                self.sequence = [response1 valueForKey:@"sequence"];
                [self closeRJ];
//
            }else{
                BOOL isZan = [[self.photoInfo valueForKey:@"isZan"]boolValue];
                int good = [[self.photoInfo valueForKey:@"good"]intValue];
                if (isZan) {
                    good --;
                }else good ++;
                [self.photoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
                [self.photoInfo setValue:[NSNumber numberWithInt:good] forKey:@"good"];
                [self setGoodButton];
                [self.good_button setEnabled:YES];
                
            }
            
        }
            break;
        default:
        {
            [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常" WithDelegate:self WithCancelTitle:@"确定"];
            
        }
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger comment_num = 0;
    if (self.pcomment_list) {
        comment_num = [self.pcomment_list count];
    }
    return 1 + comment_num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        float height = self.photo.size.height *320.0/self.photo.size.width;
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, self.specificationHeight)];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,height)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height, 320, 3)];
        [label setBackgroundColor:[UIColor colorWithRed:252/255.0 green:109/255.0 blue:67/255.0 alpha:1.0]];
        imageView.image = self.photo;
        [cell addSubview:imageView];
        [cell addSubview:label];
        
        UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:imageView.frame];
        [back addTarget:self action:@selector(backToDisplay) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:back];
        
        UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(50, height+13, 150, 12)];
        [author setFont:[UIFont systemFontOfSize:14]];
        [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
        [author setBackgroundColor:[UIColor clearColor]];
        author.text = [self.photoInfo valueForKey:@"author"];
        [cell addSubview:author];
        
        UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(50, height+28, 150, 13)];
        [date setFont:[UIFont systemFontOfSize:11]];
        [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        date.text = [self.photoInfo valueForKey:@"time"];
        [date setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:date];
        
        NSLog(@"%f",self.specificationHeight);
        UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(50, height+38, 260, self.specificationHeight+15)];
        [specification setFont:[UIFont systemFontOfSize:12]];
        [specification setNumberOfLines:0];
        specification.text = [self.photoInfo valueForKey:@"specification"];
        [specification setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:specification];
        
        if ([[self.photoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
            self.delete_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.delete_button setFrame:CGRectMake(275, height+53+self.specificationHeight, 35, 20)];
            [self.delete_button setTitle:@" 删除" forState:UIControlStateNormal];
            [self.delete_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.delete_button setTitleColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:0.5] forState:UIControlStateHighlighted];
            [self.delete_button addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:self.delete_button];
        }
        
        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, height+13, 30, 30)];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar authorId:[self.photoInfo valueForKey:@"author_id"]];
        [getter getAvatar];
        [cell addSubview:avatar];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        return cell;
    
    
    }else{
        //cell = [[UITableViewCell alloc]init];
        static NSString *CellIdentifier = @"pCommentCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([PcommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        cell = (PcommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary* Pcomment = self.pcomment_list[indexPath.row - 1];
        NSString* commentText = [Pcomment valueForKey:@"content"];
        
        ((PcommentTableViewCell *)cell).author.text = [Pcomment valueForKey:@"author"];
        ((PcommentTableViewCell *)cell).authorName = [Pcomment valueForKey:@"author"];
        ((PcommentTableViewCell *)cell).authorId = [Pcomment valueForKey:@"author_id"];
        ((PcommentTableViewCell *)cell).origincomment = [Pcomment valueForKey:@"content"];
        ((PcommentTableViewCell *)cell).controller = self;
        ((PcommentTableViewCell *)cell).date.text = [[Pcomment valueForKey:@"time"] substringWithRange:NSMakeRange(5, 11)];
        float commentWidth = 0;
        ((PcommentTableViewCell *)cell).pcomment_id = [Pcomment valueForKey:@"pcomment_id"];
        if ([[Pcomment valueForKey:@"pcomment_id"] intValue] == -1 ) {
            commentWidth = 230;
            [((PcommentTableViewCell *)cell).waitView startAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }else if([[Pcomment valueForKey:@"pcomment_id"] intValue] == -2 ){
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            commentWidth = 230;
            [((PcommentTableViewCell *)cell).resend_Button setHidden:NO];
            [((PcommentTableViewCell *)cell).resend_Button addTarget:self action:@selector(resendComment:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            commentWidth = 255;
            [((PcommentTableViewCell *)cell).waitView stopAnimating];
            [((PcommentTableViewCell *)cell).resend_Button setHidden:YES];
        }

        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:((PcommentTableViewCell *)cell).avatar authorId:[Pcomment valueForKey:@"author_id"]];
        [getter getAvatar];
        
        
        int height = [self calculateTextHeight:commentText width:255.0 fontSize:12.0];
        
        MLEmojiLabel* comment =((PcommentTableViewCell *)cell).comment;
        if (!comment){
            comment = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(50, 24, 255, height)];
            ((PcommentTableViewCell *)cell).comment = comment;
        }
        else [comment setFrame:CGRectMake(50, 24, commentWidth, height)];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:12.0f];
        comment.backgroundColor = [UIColor clearColor];
        comment.lineBreakMode = NSLineBreakByCharWrapping;
        
        
        comment.emojiText = [Pcomment valueForKey:@"content"];
        //[comment.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [comment setBackgroundColor:[UIColor clearColor]];
        [cell setFrame:CGRectMake(0, 0, 320, 32 + height)];
        
        UIView* backguand = ((PcommentTableViewCell *)cell).background;
        if (!backguand){
            backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 32+height)];
            ((PcommentTableViewCell *)cell).background = backguand;
        }
        else [backguand setFrame:CGRectMake(10, 0, 300, 32+height)];
        [backguand setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        [cell addSubview:backguand];
        [cell sendSubviewToBack:backguand];
        [cell addSubview:comment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setUserInteractionEnabled:YES];
        return cell;
        
    }
    
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if (indexPath.row == 0) {
        self.specificationHeight = [self calculateTextHeight:[self.photoInfo valueForKey:@"specification"] width:260.0 fontSize:12.0];
        NSLog(@"%f",self.specificationHeight);
        height = self.photo.size.height *320.0/self.photo.size.width;
        height += 3;
        height += 50;
        height += 30;//delete button
        height += self.specificationHeight;
        
    }else{
        NSDictionary* Pcomment = self.pcomment_list[indexPath.row - 1];
        float commentWidth = 0;
        NSString* commentText = [Pcomment valueForKey:@"content"];
        if ([[Pcomment valueForKey:@"pcomment_id"] intValue] > 0) {
            commentWidth = 255;
        }else commentWidth = 230;
        
        height = [self calculateTextHeight:commentText width:commentWidth fontSize:12.0];
        height += 32;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isKeyBoard) {
        [self.inputTextView resignFirstResponder];
        return;
    }
    NSLog(@"kkkk");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //[self.navigationController popToViewController:self.photoDisplayController animated:YES];
    }else{
        NSLog(@"aaa");
        PcommentTableViewCell *cell = (PcommentTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.background setAlpha:0.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell.background setAlpha:1.0];
        });
        if ([cell.pcomment_id intValue] < 0) return;
        self.herName = cell.authorName;
        if ([cell.authorId intValue] != [[MTUser sharedInstance].userid intValue]) {
            self.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@:",_herName];
        }else self.inputTextView.placeHolder = @"说点什么吧";
        [self.inputTextView becomeFirstResponder];
        self.repliedId = cell.authorId;
    }
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeRJ) userInfo:nil repeats:NO];
//    if (refreshView == _header) {
//        _Headeropen = YES;
//        self.master_sequence = [NSNumber numberWithInt:0];
//    }else
    _Footeropen = YES;
    [self pullMainCommentFromAir];
}
#pragma mark - keyboard observer method
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    self.isKeyBoard = YES;
    if (self.isEmotionOpen) {
        [self button_Emotionpress:nil];
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.controlView.frame;
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
    //self.inputField.text = @"";
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

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"成功分享" WithDelegate:self WithCancelTitle:@"确定"];
    }
}
#pragma mark - UITextView Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = _inputTextView.frame;
    float change = _inputTextView.contentSize.height - frame.size.height;
    if (change != 0 && _inputTextView.contentSize.height < 120) {
        frame.size.height = _inputTextView.contentSize.height;
        [_inputTextView setFrame:frame];
        frame = _commentView.frame;
        frame.origin.y -= change;
        frame.size.height += change;
        [_commentView setFrame:frame];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:{
            NSInteger cancelBtnIndex = alertView.cancelButtonIndex;
            NSInteger okBtnIndex = alertView.firstOtherButtonIndex;
            if (buttonIndex == cancelBtnIndex) {
                ;
            }
            else if (buttonIndex == okBtnIndex)
            {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
                [dictionary setValue:self.eventId forKey:@"event_id"];
                [dictionary setValue:@"delete" forKey:@"cmd"];
                [dictionary setValue:self.photoId forKey:@"photo_id"];
                HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
                [httpSender sendPhotoMessage:dictionary withOperationCode: UPLOADPHOTO finshedBlock:^(NSData *rData) {
                    if (rData) {
                        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
                        rData = [temp dataUsingEncoding:NSUTF8StringEncoding];
                        NSLog(@"received Data: %@",temp);
                        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
                        NSNumber *cmd = [response1 valueForKey:@"cmd"];
                        switch ([cmd intValue]) {
                            case NORMAL_REPLY:
                            {
                                //百度云 删除
                                CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
                                [cloudOP deletePhoto:[NSString stringWithFormat:@"/images/%@",[self.photoInfo valueForKey:@"photo_name"]]];
                                //数据库 删除
                                [self deletePhotoInfoFromDB];
                                
                                
                            }
                                break;
                            default:
                            {
                                [self.delete_button setEnabled:YES];
                                UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"图片删除成功" WithDelegate:self WithCancelTitle:@"确定"];
                                [alert setTag:1];
                            }
                        }
                        
                    }else{
                        [self.delete_button setEnabled:YES];
                        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
                    }
                    
                }];
            }

        }
            break;
        case 1:{
            ((PictureWallViewController*)self.controller).canReloadPhoto = YES;
            [self.navigationController popToViewController:self.controller animated:YES];
        }
        default:
            break;
    }
}

#pragma mark - CloudOperationDelegate
-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (status){
        UIAlertView *alert = [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"图片删除成功" WithDelegate:self WithCancelTitle:@"确定"];
        [alert setTag:1];
        [self.delete_button setEnabled:YES];
    }else{
        [self.delete_button setEnabled:YES];
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"网络异常，请重试" WithDelegate:nil WithCancelTitle:@"确定"];
    }

}


@end
