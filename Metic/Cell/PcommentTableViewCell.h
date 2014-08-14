//
//  PcommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-7-6.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PcommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *author;
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSNumber *authorId;
@property (strong, nonatomic) IBOutlet NSNumber *pcomment_id;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;

@end
