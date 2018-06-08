//
//  ViewController.m
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/05/31.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import "ViewController.h"
@import Firebase;
@import FirebaseUI;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    //[super viewDidLoad];
    [FIRApp configure];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user) {
        self.UserNameTextField.text = user.displayName;
        self.MailTextField.text = user.email;
        // ...
    }

}

//登录状态确认
-(BOOL)isUserSignedIn{
    NSLog(@"%s","isUserSignedIn");
    FIRUser *currentUser = [[FIRAuth auth] currentUser];
    NSLog(@"%@",currentUser);
    if(currentUser == NULL){
        return false;
    }
    else{
        return true;
    }
}
//在呈现身份验证视图并且用户成功登录后，系统会将结果返回给 didSignInWithUser:error: 方法中的 FirebaseUI 身份验证委托
- (void)authUI:(FUIAuth *)authUI
didSignInWithUser:(nullable FIRUser *)user
         error:(nullable NSError *)error {
    if (error == nil) {
        NSLog(@"%@",user.email);
        NSLog(@"%@",user.displayName);
    }
    else{
        NSLog(@"%@",error);
        NSLog(@"%s","login error");
    }
}

//Google 和 Facebook 注册流程的结果
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
        [self dismissViewControllerAnimated:YES completion:nil];
    return [[FUIAuth defaultAuthUI] handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//SignIN按钮
- (IBAction)SigninBtn:(id)sender {
    if([self isUserSignedIn] == false){
        //authUI 初始化
        FUIAuth *authUI = [FUIAuth defaultAuthUI];
        authUI.delegate = self;
        NSArray<id<FUIAuthProvider>> *providers = @[[[FUIFacebookAuth alloc] init],[[FUIGoogleAuth alloc] init],[[FUITwitterAuth alloc] init]];
        authUI.providers = providers;
        //authUI ViewController 实例
        UINavigationController *controller = [authUI authViewController];
        if(controller){
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                                 message:@"You have signed in already!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK Action");
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        NSLog(@"%s","SignedIn");
    }
    
}
//SignOUT按钮
- (IBAction)SignoutBtn:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                                 message:@"Sign out success!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK Action");
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        NSLog(@"%s","SignedIn");
        self.UserNameTextField.text = @"";
        self.MailTextField.text = @"";
        NSLog(@"SignedOut");
    }
}

@end
