#import "BOAlertController.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"

@interface BOAlertController()

@property (nonatomic, strong) NSString              *title;
@property (nonatomic, strong) NSString              *message;
@property (nonatomic, weak) UIViewController        *inViewController;
@property (nonatomic, strong) NSMutableDictionary   *buttonInfoDict;

@end

@implementation BOAlertController

- (id)initWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)inViewController
{
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.inViewController = inViewController;
    }
    return self;
}

- (NSMutableDictionary *)buttonInfoDict
{
    if (_buttonInfoDict == nil) {
        _buttonInfoDict = [NSMutableDictionary dictionary];
    }
    return _buttonInfoDict;
}

- (void)addButton:(RIButtonItem *)button type:(RIButtonItemType)itemType
{
    if (button == nil || ![button isKindOfClass:[RIButtonItem class]]) {
        return;
    }
    switch (itemType) {
        case RIButtonItemType_Cancel:
        {
            [self.buttonInfoDict setObject:button forKey:@"RIButtonItemType_Cancel"];
        }
            break;
        case RIButtonItemType_Destructive:
        {
            [self.buttonInfoDict setObject:button forKey:@"RIButtonItemType_Destructive"];
        }
            break;
        case RIButtonItemType_Other:
        {
            NSMutableArray *otherArray = self.buttonInfoDict[@"RIButtonItemType_Other"];
            if (otherArray == nil) {
                otherArray = [NSMutableArray array];
            }
            [otherArray addObject:button];
            [self.buttonInfoDict setObject:otherArray forKey:@"RIButtonItemType_Other"];
        }
            break;
            
        default:
            break;
    }
}

- (void)showInView:(UIView *)view
{
    if (isIOS8) {
        [self showIOS8ViewWithType:BOAlertControllerType_ActionSheet];
        
    } else {
        [self ios7showInView:view];
    }
}

- (void)show
{
    if (isIOS8) {
        [self showIOS8ViewWithType:BOAlertControllerType_AlertView];
        
    } else {
        [self ios7Show];
    }
}

- (void)showIOS8ViewWithType:(BOAlertControllerType)viewType
{
    if (self.inViewController == nil) {
        return;
    }
    
    UIAlertController *alertController = nil;
    switch (viewType) {
        case BOAlertControllerType_AlertView:
        {
            alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleAlert];
        }
            break;
        case BOAlertControllerType_ActionSheet:
        {
            alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleActionSheet];
        }
            break;
            
        default:
            break;
    }
    
    RIButtonItem *cancelItem = self.buttonInfoDict[@"RIButtonItemType_Cancel"];
    if (cancelItem != nil) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelItem.label style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            cancelItem.action();
        }];
        [alertController addAction:cancelAction];
    }
    
    RIButtonItem *destructiveItem = self.buttonInfoDict[@"RIButtonItemType_Destructive"];
    if (destructiveItem != nil) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveItem.label style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            destructiveItem.action();
        }];
        [alertController addAction:destructiveAction];
    }
    
    NSArray *otherItems = self.buttonInfoDict[@"RIButtonItemType_Other"];
    if (otherItems != nil && otherItems.count > 0) {
        for (RIButtonItem *buttonItem in otherItems) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:buttonItem.label style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                buttonItem.action();
            }];
            [alertController addAction:otherAction];
        }
    }
    
    [self.inViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)ios7showInView:(UIView *)view
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.title cancelButtonItem:self.buttonInfoDict[@"RIButtonItemType_Cancel"] destructiveButtonItem:self.buttonInfoDict[@"RIButtonItemType_Destructive"] otherButtonItems: nil];
    
    NSArray *otherItems = self.buttonInfoDict[@"RIButtonItemType_Other"];
    if (otherItems != nil && otherItems.count > 0) {
        for (RIButtonItem *buttonItem in otherItems) {
            [actionSheet addButtonItem:buttonItem];
        }
    }
    [actionSheet showInView:view];
}

- (void)ios7Show
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message cancelButtonItem:self.buttonInfoDict[@"RIButtonItemType_Cancel"] otherButtonItems:nil];
    
    RIButtonItem *destructiveItem = self.buttonInfoDict[@"RIButtonItemType_Destructive"];
    if (destructiveItem != nil) {
        [alertView addButtonItem:destructiveItem];
    }
    
    NSArray *otherItems = self.buttonInfoDict[@"RIButtonItemType_Other"];
    if (otherItems != nil && otherItems.count > 0) {
        for (RIButtonItem *buttonItem in otherItems) {
            [alertView addButtonItem:buttonItem];
        }
    }
    
    [alertView show];
}

@end