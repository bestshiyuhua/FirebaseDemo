//
//  RssTableViewCell.h
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/06/22.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RssTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *RssImageView;
@property (weak, nonatomic) IBOutlet UILabel *RssTitle;
@property (weak, nonatomic) IBOutlet UILabel *RssAuther;
@property (weak, nonatomic) IBOutlet UILabel *RssDate;

@end
