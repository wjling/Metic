//
//  NameSettingViewController.m
//  Metic
//
//  Created by mac on 14-7-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "NameSettingViewController.h"
#import "SVProgressHUD.h"

@interface NameSettingViewController ()
{
    NSString* newName;
    NSString* DB_path;
    
    UILabel* note;
}

@end

@implementation NameSettingViewController


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
    // Do any additional setup after loading the view.
    [CommonUtils addLeftButton:self isFirstPage:NO];
    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
//    self.name_textField.delegate = self;
    
    note = [[UILabel alloc]init];
    [note setFrame:CGRectMake(self.view.bounds.size.width / 2.0 - 75, 80, 150, 30)];
    note.text = @"昵称不能超过13个字";
    note.font = [UIFont systemFontOfSize:13];
    note.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:note];
    note.alpha = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.name_textField];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetected)];
    [self.view addGestureRecognizer:tap];
}

-(void)tapDetected
{
    [self.name_textField resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:self.name_textField];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)confirmClicked:(id)sender {
    newName = self.name_textField.text;
    if ([newName isEqualToString:@""]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"提示" WithMessage:@"新的昵称不能为空" WithDelegate:self WithCancelTitle:@"OK"];
    }
    else
    {
        [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        NSDictionary* json = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid,@"id",newName,@"name",nil  ];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
        [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
        [SVProgressHUD showWithStatus:@"请稍候" maskType:SVProgressHUDMaskTypeGradient];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
//        [self.confirm_barButton setEnabled:NO];
        
    }
    
}

-(void)dismissHUD:(id)sender
{
    [SVProgressHUD dismissWithError:@"服务器未响应" afterDelay:1.5];
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
//    [self.confirm_barButton setEnabled:YES];
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            [MTUser sharedInstance].name = newName;
            [AppDelegate refreshMenu];	
            NSLog(@"昵称修改成功");
            [SVProgressHUD dismissWithSuccess:@"昵称修改成功" afterDelay:2];
//            [CommonUtils showToastWithTitle:@"系统提示" withMessage:@"昵称修改成功" withDelegate:self withDuaration:1.5];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case USER_NAME_EXIST:  //120
        {
            [SVProgressHUD dismissWithError:@"该昵称已存在" afterDelay:2];
//            [CommonUtils showToastWithTitle:@"系统提示" withMessage:@"该昵称已存在，请重试" withDelegate:self withDuaration:1.5];
        }
            break;
            
        default:
            NSLog(@"昵称修改失败");
            [SVProgressHUD dismissWithError:@"昵称修改失败，请检查是否包含非法字符" afterDelay:1.5];
//            [CommonUtils showToastWithTitle:@"系统提示" withMessage:@"昵称修改失败，请重试" withDelegate:self withDuaration:1.5];
            break;
    }
    
    
}

-(void)textFieldEditChanged:(NSNotification*)obj
{
    NSInteger kMaxLength = 13;
    UITextField* textField = (UITextField*)obj.object;
    NSString* toBeString = textField.text;
    //获取当前输入法
    NSString* lang = [[UITextInputMode currentInputMode] primaryLanguage];
//    NSLog(@"当前输入法： %@", lang);
    if ([lang isEqualToString:@"zh-Hans"]) { //当前输入法是中文
        UITextRange* selectedRange = [textField markedTextRange]; //高亮的文本范围
        UITextPosition* position = [textField positionFromPosition:selectedRange.start offset:0];
        
        if (!position) { //不存在高亮的文本
            if (toBeString.length > kMaxLength) { //超过了最大长度限制
                textField.text = [toBeString substringToIndex:kMaxLength];
                if (note.alpha < 1) {
                    [self changeNoteAlpha:1];
                    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fadeNote) userInfo:nil repeats:NO];
                }
            }
            
            else{
                
            }
        }
    }
    else{ //非中文输入法
        
        if (toBeString.length > kMaxLength) { //超过了最大长度
            textField.text = [toBeString substringToIndex:kMaxLength];
            if (note.alpha < 1) {
                [self changeNoteAlpha:1];
                [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fadeNote) userInfo:nil repeats:NO];
            }
        }

    }
}

-(void)changeNoteAlpha:(float)alpha
{
    [UIView beginAnimations:@"showLabel" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    // Make the animatable changes.
    note.alpha = alpha;
    // Commit the changes and perform the animation.
    [UIView commitAnimations];
}

-(void)fadeNote
{
    [self changeNoteAlpha:0];
}

@end
