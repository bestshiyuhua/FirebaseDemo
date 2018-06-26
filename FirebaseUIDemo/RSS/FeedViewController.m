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

@interface FeedViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *FeedTableView;
@property (strong, nonatomic) NSArray *feedArray;
@property(nonatomic,strong) NSMutableArray* feedInfos;
@property(nonatomic,strong) IDNFeedInfo * currentInfo;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // datasource & delegate
    self.FeedTableView.dataSource = self;
    self.FeedTableView.delegate = self;
    self.title = @"Feed List";
    // get Feeds from plist
    [self getFeedFromPlist];
    [self setFeed];
}

- (void)setFeed{
    [self view];
    self.feedInfos = [NSMutableArray new];
    int count = self.feedArray.count;
    NSLog(@"Count:%d",count);
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

- (void)getFeedFromPlist{
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"FeedList" ofType:@"plist"];
    self.feedArray = [[NSArray alloc]initWithContentsOfFile:plistPath];
    NSLog(@"%@",self.feedArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedArray.count;
    //return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[FeedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (self.feedInfos != nil && ![self.feedInfos isKindOfClass:[NSNull class]] && self.feedInfos.count != 0){
        IDNFeedInfo* info = self.feedInfos[indexPath.row];
        cell.FeedTitle.text = info.title;
        cell.FeedSummary.text = info.summary;
    }
    else{
        cell.FeedTitle.text = @"Loading...";
        cell.FeedSummary.text = @"Loading...";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentInfo = self.feedInfos[indexPath.row];
    [self performSegueWithIdentifier:@"ShowRss" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowRss"]) {
        // 获取连线时所指的界面（VC）
        RssViewController *Rss = segue.destinationViewController;
        Rss.feedInfo = self.currentInfo;
    }
}


@end
