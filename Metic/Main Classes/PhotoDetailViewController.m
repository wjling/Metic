//
//  PhotoDetailViewController.m
//  Metic
//
//  Created by ligang6 on 14-7-4.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoDisplayViewController.h"
#import "../Cell/PcommentTableViewCell.h"
#import "HomeViewController.h"
#import "../Utils/CommonUtils.h"

@interface PhotoDetailViewController ()
@property (nonatomic,strong)NSNumber* sequence;
@property (nonatomic,strong)UIButton * delete_button;
@property (strong, nonatomic) IBOutlet UIButton *good_button;
@property (strong, nonatomic) IBOutlet UIButton *download_button;
@property float specificationHeight;
@property (nonatomic,strong) NSArray * pcomment_list;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property BOOL isKeyBoard;

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
    self.sequence = [NSNumber numberWithInt:0];
    self.isKeyBoard = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initButtons];
    [self setGoodButton];

    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    self.sequence = [NSNumber numberWithInt:0];
    [self pullMainCommentFromAir];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initButtons
{
    for (UIButton* button in self.buttons) {
        UIImage *colorImage = [CommonUtils createImageWithColor:[UIColor colorWithRed:85/255.0 green:203/255.0 blue:171/255.0 alpha:1.0] ];
        [button setBackgroundImage:colorImage forState:UIControlStateHighlighted];
        [button resignFirstResponder];
    }
    
}

-(void) setGoodButton
{
    if ([[self.photoInfo valueForKey:@"isZan"] boolValue]) {
        [self.buttons[0] setImage:[UIImage imageNamed:@"图片评论icon点赞"] forState:UIControlStateNormal];
    }else [self.buttons[0] setImage:[UIImage imageNamed:@"图片评论icon图标1"] forState:UIControlStateNormal];
}

-(float)calculateTextHeight:(NSString*)text type:(int)type
{
//    UITextView* cal;
    float width,height = 0;
    switch (type) {
        case 1:
            width = 270;
            break;
        case 2:
            width = 255;
            break;
            
        default:
            break;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    //设置自动行数与字符换行，为0标示无限制
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;//换行方式
    UIFont *font = [UIFont systemFontOfSize:12.0];
    label.font = font;
    
    CGSize size = CGSizeMake(width,CGFLOAT_MAX);//LableWight标签宽度，固定的
    //计算实际frame大小，并将label的frame变成实际大小
    
    CGSize labelsize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:label.lineBreakMode];
    height = labelsize.height;
    return height < 8.0? 8.0:height+1;
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
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD];
}

- (IBAction)comment:(id)sender {
    [self.commentView setHidden:NO];
    [self.view bringSubviewToFront:self.commentView];
}

- (IBAction)share:(id)sender {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"53bb542e56240ba6e80a4bfb"
                                      shareText:@"weshare"
                                     shareImage:self.photo
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
                                       delegate:self];
}

- (IBAction)download:(id)sender {
    [self.download_button setEnabled:NO];
    UIImageWriteToSavedPhotosAlbum(self.photo,self, @selector(downloadComplete:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    //UIImageWriteToSavedPhotosAlbum(self.photo, self, @selector(downloadComplete),nil);
}

- (IBAction)publishComment:(id)sender {
    NSString *comment = [((UITextField*)[self.commentView viewWithTag:10]).text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    if ([comment isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"写点内容吧" WithDelegate:self WithCancelTitle:@"确定"];
        return;
    }
    [[self.commentView viewWithTag:10] resignFirstResponder];
    ((UITextField*)[self.commentView viewWithTag:10]).text = @"";
    NSLog(comment,nil);
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.photoId forKey:@"photo_id"];
    [dictionary setValue:comment forKey:@"content"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_PCOMMENT];
}

- (void)downloadComplete:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo{
    [self.download_button setEnabled:YES];
    if (error){
        // Do anything needed to handle the error or display it to the user
    }else{
        [CommonUtils showSimpleAlertViewWithTitle:@"信息" WithMessage:@"保存成功" WithDelegate:self WithCancelTitle:@"确定"];
    }
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
            if ([response1 valueForKey:@"photo_name"]) {
                self.pcomment_list = [response1 valueForKey:@"pcomment_list"];
                self.sequence = [response1 valueForKey:@"sequence"];
                [self.tableView reloadData];
            }else if ([response1 valueForKey:@"pcomment_id"]){
                self.sequence = [NSNumber numberWithInt:0];
                [self pullMainCommentFromAir];
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
    int comment_num = 0;
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
        
        UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(40, height+13, 150, 12)];
        [author setFont:[UIFont systemFontOfSize:14]];
        [author setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:186/255.0 alpha:1.0]];
        [author setBackgroundColor:[UIColor clearColor]];
        author.text = [self.photoInfo valueForKey:@"author"];
        [cell addSubview:author];
        
        UILabel* date = [[UILabel alloc]initWithFrame:CGRectMake(40, height+25, 150, 13)];
        [date setFont:[UIFont systemFontOfSize:12]];
        [date setTextColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
        date.text = [self.photoInfo valueForKey:@"time"];
        [date setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:date];
        
        NSLog(@"%f",self.specificationHeight);
        UILabel* specification = [[UILabel alloc]initWithFrame:CGRectMake(40, height+38, 270, self.specificationHeight+15)];
        [specification setFont:[UIFont systemFontOfSize:12]];
        [specification setNumberOfLines:0];
        specification.text = [self.photoInfo valueForKey:@"specification"];
        [specification setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:specification];
        
        if ([[self.photoInfo valueForKey:@"author_id"] intValue] == [[MTUser sharedInstance].userid intValue]) {
            self.delete_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.delete_button setFrame:CGRectMake(275, height+18, 35, 18)];
            [self.delete_button setTitle:@" 删除" forState:UIControlStateNormal];
            [self.delete_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.delete_button setBackgroundImage:[UIImage imageNamed:@"删除评论的背景图"] forState:UIControlStateNormal];
            [cell addSubview:self.delete_button];
        }
        
        UIImageView* avatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, height+13, 20, 20)];
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",[self.photoInfo valueForKey:@"author_id"]] type:2 cache:[MTUser sharedInstance].avatar];
        getter.mDelegate = self;
        [getter setTypeOption2:[self.photoInfo valueForKey:@"author_id"]];
        [getter getPhoto];
        [cell addSubview:avatar];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        return cell;
    
    
    }else{
        cell = [[UITableViewCell alloc]init];
        static NSString *CellIdentifier = @"pCommentCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([PcommentTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        PcommentTableViewCell* cell1 = (PcommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary* Pcomment = self.pcomment_list[indexPath.row - 1];
        NSString* commentText = [Pcomment valueForKey:@"content"];
        
        cell1.author.text = [Pcomment valueForKey:@"author"];
        cell1.date.text = [[Pcomment valueForKey:@"time"] substringWithRange:NSMakeRange(5, 11)];
        //cell1.comment.text = [Pcomment valueForKey:@"content"];

        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:cell1.avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",[Pcomment valueForKey:@"author_id"]] type:2 cache:[MTUser sharedInstance].avatar];
        getter.mDelegate = self;
        [getter setTypeOption2:[self.photoInfo valueForKey:@"author_id"]];
        [getter getPhoto];
        
        
        int height = [self calculateTextHeight:commentText type:2];
        UILabel* comment = [[UILabel alloc]initWithFrame:CGRectMake(50, 24, 255, height)];
        [comment setFont:[UIFont systemFontOfSize:12]];
        [comment setNumberOfLines:0];
        comment.text = [Pcomment valueForKey:@"content"];
        //[comment.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [comment setBackgroundColor:[UIColor clearColor]];
        [cell setFrame:CGRectMake(0, 0, 320, 32 + height)];
        
        UIView *backguand = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 32+height)];
        [backguand setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
        
        
        [cell setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
        [cell addSubview:backguand];
        [cell addSubview:cell1];
        [cell addSubview:comment];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
        
    }
    
}
#pragma mark - PhotoGetterDelegate
-(void)finishwithNotification:(UIImageView *)imageView image:(UIImage *)image type:(int)type container:(id)container
{
    imageView.image = image;
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if (indexPath.row == 0) {
        self.specificationHeight = [self calculateTextHeight:[self.photoInfo valueForKey:@"specification"] type:1];
        NSLog(@"%f",self.specificationHeight);
        height = self.photo.size.height *320.0/self.photo.size.width;
        height += 3;
        height += 50;
        height += self.specificationHeight;
        
    }else{
        NSDictionary* Pcomment = self.pcomment_list[indexPath.row - 1];
        NSString* commentText = [Pcomment valueForKey:@"content"];
        height = [self calculateTextHeight:commentText type:2];
        height += 32;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isKeyBoard) {
        [[self.commentView viewWithTag:10] resignFirstResponder];
        return;
    }
    if (indexPath.row == 0) {
        [self.navigationController popToViewController:self.photoDisplayController animated:YES];
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

@end
