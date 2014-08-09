//
//  BDSuggestLabel.h
//  BingDic
//
//  Created by 854072335 yxlong on 13-1-3.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface BDSuggestLabel : UILabel{
    @private
//    NSString * keyWord;
//    UIColor * keyWordColor;
//    UIFont * keyWordFont;
}
@property(nonatomic, copy) NSString * keyWord;
@property(nonatomic, copy) UIColor * keyWordColor;
@property(nonatomic, copy) UIFont * keyWordFont;
@end
