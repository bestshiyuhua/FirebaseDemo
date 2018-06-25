//
//  RssViewController.m
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/06/22.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import "RssViewController.h"
#import "RssTableViewCell.h"
#import "IDNFeedParser.h"
#import "WebViewController.h"
#import "UIViewController+IDNPrompt.h"

@interface RssViewController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong) NSArray* feedItems;
@property (weak, nonatomic) IBOutlet UITableView *RssTableView;

@end

@implementation RssViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.RssTableView.dataSource = self;
    self.RssTableView.delegate = self;
    self.RssTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self performSelector:@selector(setFeedInfo)];
}
- (void)setFeedInfo
{
    [self view]; //强制loadView
    NSLog(@"loadview");
    [self.navigationController prompting:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 获取文章列表
        NSArray* items = [IDNFeedParser feedItemsWithUrl:@"https://japanese.engadget.com/rss.xml"];
        if(items==nil) {
            //失败
            [self.navigationController prompt:@"Loading Error" duration:2];
        }
        
        else //成功
        {
            // 解析完成后在主线程更新显示
            dispatch_async(dispatch_get_main_queue(), ^{
                self.feedItems = items;
                NSLog(@"count:%lu",(unsigned long)self.feedItems.count);
                [self.RssTableView reloadData];
                [self.navigationController stopPrompt];
                NSLog(@"loaded");
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RssCell";
    
    RssTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[RssTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    IDNFeedItem *item = self.feedItems[indexPath.row];
    //title
    cell.RssTitle.text = item.title;
    //image
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.image]]];
    cell.RssImageView.image = [self performSelector:@selector(cropSquareImage:) withObject:image];
    //author
    cell.RssAuther.text = item.author;
    //date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate: item.date];
    cell.RssDate.text = dateString;

    return cell;
}
-(UIImage *)cropSquareImage:(UIImage *)image{
    
    CGImageRef sourceImageRef = [image CGImage];//将UIImage转换成CGImageRef
    CGFloat _imageWidth = image.size.width * image.scale;
    CGFloat _imageHeight = image.size.height * image.scale;
    CGFloat _width = _imageWidth > _imageHeight ? _imageHeight : _imageWidth;
    CGFloat _offsetX = (_imageWidth - _width) / 2;
    CGFloat _offsetY = (_imageHeight - _width) / 2;
    
    CGRect rect = CGRectMake(_offsetX, _offsetY, _width, _width);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    return newImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IDNFeedItem* item = self.feedItems[indexPath.row];
    
    WebViewController* web = [WebViewController new];
    web.url = item.link;
    web.title = item.title;
    [self.navigationController pushViewController:web animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
