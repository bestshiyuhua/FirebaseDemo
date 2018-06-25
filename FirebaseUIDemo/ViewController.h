//
//  ViewController.h
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/05/31.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)RssBtn:(id)sender;
- (IBAction)SigninBtn:(id)sender;
- (IBAction)SignoutBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *UserNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *MailTextField;
@end

