//
//  FeedViewController.m
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/06/26.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedTableViewCell.h"
#import "IDNFeedParser.h"
#import "UIViewController+IDNPrompt.h"
#import "RssViewController.h"
@import Firebase;

@interface FeedViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *editBtnTitle;
@property (weak, nonatomic) IBOutlet UITableView *FeedTableView;
@property (strong, nonatomic) IBOutlet UITextField *TextField;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property(nonatomic,strong) NSMutableArray* feedInfos;
@property(nonatomic,strong) IDNFeedInfo * currentInfo;
@property (nonatomic, readwrite) FIRFirestore *db;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //firestore 初始化
    FIRFirestoreSettings *settings = [[FIRFirestoreSettings alloc] init];
    settings.persistenceEnabled = YES;
    self.db = [FIRFirestore firestore];
    self.db.settings = settings;
    // datasource & delegate
    self.FeedTableView.dataSource = self;
    self.FeedTableView.delegate = self;
    self.title = @"Feed List";
    // get Feeds from plist
    [self getFeed];
    self.TextField.hidden = YES;//隐藏addcell
    //self.feedArray = [[NSMutableArray alloc] initWithCapacity:0];

}

- (void)getFeed{
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user != nil){
        //登录状态
        NSLog(@"%@",user.displayName);
        [self getFeedFromFirestore];
    }
    else{
        //未登录状态
        [self getFeedFromPlist];
        NSLog(@"user not log in");
        [self setFeed];
    }
}
//从plist获取Feed
- (void)getFeedFromPlist{
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"FeedList" ofType:@"plist"];
    self.feedArray = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
    NSLog(@"%@",self.feedArray);
}

- (void)getFeedFromFirestore{
    
    FIRUser *user = [FIRAuth auth].currentUser;
    FIRDocumentReference *docRef = [[[[self.db collectionWithPath:@"users"] documentWithPath:user.uid] collectionWithPath:@"subs"] documentWithPath:@"sub"];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            // Document data may be nil if the document exists but has no keys or values.
            NSLog(@"%@",self.feedArray);
            self.feedArray = [snapshot.data objectForKey:@"sub1"];
            NSLog(@"%@",self.feedArray);
            [self setFeed];

        } else {
            NSLog(@"Document does not exist");
            [self getFeedFromPlist];
            [docRef setData:@{
                              @"sub1":self.feedArray
                              }
                      merge:YES];
            [self setFeed];
        }
        
    }];
}
//下载解析RSS
- (void)setFeed{
    [self view];
    self.feedInfos = [NSMutableArray new];
    NSInteger count = [self.feedArray count];
    NSLog(@"Count:%ld",(long)count);
    [self.navigationController prompting:@"Loading RSS Feed"];
    // 在后台线程下载解析RSS
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i<count; i++){
            IDNFeedInfo *info = [IDNFeedParser feedInfoWithUrl:self.feedArray[i]];
            [self.feedInfos addObject:info];
        }
        if(self.feedInfos==nil) //失败
            [self.navigationController prompt:@"读取RSS源信息失败" duration:2];
        else //成功
        {
            [self.navigationController stopPrompt];
            // 解析完成后在主线程更新显示
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.FeedTableView reloadData];
            });
        }
    });
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedInfos count]+1;//因为有add 所以多一个
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell复用
    if(cell == nil){
        cell = [[FeedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //add cell
    BOOL b_addCell = (indexPath.row == self.feedInfos.count);
    if (!b_addCell){
        //从FeedInfos读取Feed数据
        if (self.feedInfos != nil && ![self.feedInfos isKindOfClass:[NSNull class]] && self.feedInfos.count != 0){
            //如果feedInfos不为空
            IDNFeedInfo* info = self.feedInfos[indexPath.row];
            cell.FeedTitle.text = info.title;
            cell.FeedSummary.text = info.summary;
        }
        else{
            cell.FeedTitle.text = @"Loading...";
            cell.FeedSummary.text = @"Loading...";
        }
    }
    else{
        //给add cell加subview
        self.TextField.frame = CGRectMake(10, 0, 300, 44);
        self.TextField.borderStyle = UITextBorderStyleNone;
        self.TextField.placeholder = @"Add...";
        self.TextField.text = @"";
        //label置空
        cell.FeedTitle.text = @"";
        cell.FeedSummary.text = @"";
        [cell.contentView addSubview:self.TextField];
    }
    return cell;
}
//跳到某个RSS文章列表
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取当前cell的info
    self.currentInfo = self.feedInfos[indexPath.row];
    [self performSegueWithIdentifier:@"ShowRss" sender:self];
}

#pragma mark - Navigation

//给下个页面传info数据
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowRss"]) {
        // 获取连线时所指的界面（VC）
        RssViewController *Rss = segue.destinationViewController;
        Rss.feedInfo = self.currentInfo;
    }
}

//右上角编辑按钮
- (IBAction)editBtn:(id)sender {
    if([_editBtnTitle.currentTitle isEqualToString:@"Edit"]){
        //进入编辑状态
        [self.editBtnTitle setTitle:@"Cancle" forState:UIControlStateNormal];
        [self.FeedTableView setEditing:YES animated:YES];
        self.TextField.hidden = NO;
    }
    else{
        //退出编辑状态
        [self.editBtnTitle setTitle:@"Edit" forState:UIControlStateNormal];
        [self.FeedTableView setEditing:NO animated:NO];
        self.TextField.hidden = YES;
    }
}
//插入和删除的状态图标（-）（+）
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.feedInfos count]){
        return UITableViewCellEditingStyleInsert;
    }
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

//插入和删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    //获取database引用
    FIRUser *user = [FIRAuth auth].currentUser;


    //判断删除还是插入
    if (editingStyle == UITableViewCellEditingStyleDelete){
        //删除cell数据源
        [self.feedInfos removeObjectAtIndex:indexPath.row];
        if (user){
            [self.feedArray removeObjectAtIndex:indexPath.row];
            FIRDocumentReference *docRef = [[[[self.db collectionWithPath:@"users"] documentWithPath:user.uid] collectionWithPath:@"subs"] documentWithPath:@"sub"];
            [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                if (snapshot.exists) {
                    // 更新数据
                    [docRef setData:@{
                                      @"sub1":self.feedArray
                                      }
                              merge:YES];
                } else {
                    NSLog(@"Document does not exist");
                }
            }];
        }
        //删除cell
        [self.FeedTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert){
        NSString *url = @"https://cn.engadget.com/rss.xml";
        IDNFeedInfo *info = [IDNFeedParser feedInfoWithUrl:url];
        //添加数据源
        [self.feedInfos insertObject:info atIndex:[self.feedInfos count]];
        if (user){
            [self.feedArray insertObject:url atIndex:[self.feedArray count]];
            FIRDocumentReference *docRef = [[[[self.db collectionWithPath:@"users"] documentWithPath:user.uid] collectionWithPath:@"subs"] documentWithPath:@"sub"];
            [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                if (snapshot.exists) {
                    // 更新数据
                    [docRef setData:@{
                                      @"sub1":self.feedArray
                                      }
                              merge:YES];
                } else {
                    NSLog(@"Document does not exist");
                }
            }];
        }
        //添加cell
        [self.FeedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
    }
    [self.FeedTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
