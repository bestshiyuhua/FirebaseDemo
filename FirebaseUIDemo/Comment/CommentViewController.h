//
//  Header.h
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/06/08.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CommentViewController : UIViewController
- (IBAction)sentCommentBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *commentText;

//@property(nonatomic, strong) NSArray *listTeams;
@end
