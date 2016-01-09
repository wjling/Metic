//
//  SingleSelectionAlertView.h
//  Metic
//
//  Created by mac on 14-7-17.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@protocol SingleSelectionAlertViewDelegate <NSObject>

@optional
- (void)SingleSelectionAlertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

//----------------WARNING---------------------
//请把该类定义成类变量，不要定义成局部变量（比如可以用@property和@synthesize定义该变量）。
//否则，在执行show方法的时候可能会把该变量提前释放以至于其中的点击事件造成崩溃。切记切记～～！！

@interface SingleSelectionAlertView : UIView<CustomIOS7AlertViewDelegate>
{
    NSInteger lastSelected;
    NSString* theTitle;
    CustomIOS7AlertView* customAlert;
    
}
@property NSInteger numberOfOptions;
@property (strong, nonatomic) NSMutableArray* selectionItems;
@property (strong, nonatomic) UIView* contentView;
@property (strong, nonatomic) UIScrollView* optionView;
@property (strong, nonatomic) UILabel* title_label;
@property (strong, nonatomic) NSArray* options;
@property (nonatomic) CGSize kSize;
@property (strong, nonatomic)id<SingleSelectionAlertViewDelegate> kDelegate;

- (id)initWithContentSize:(CGSize)size withTitle:(NSString*)title withOptions:(NSArray*)theOptions;
- (void)set_Options:(NSArray *)theOptions;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)changeButtonStateAfterClicked:(id)sender;
- (NSInteger)getSelectedIndex;
- (void)show;
- (void)close;

@end
