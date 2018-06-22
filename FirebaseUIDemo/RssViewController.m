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
@interface RssViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *RssTableView;

@end

@implementation RssViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.RssTableView.dataSource = self;
    self.RssTableView.delegate = self;
    self.RssTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    IDNFeedInfo *info = [IDNFeedParser feedInfoWithUrl:@"https://hnrss.org/newest"];
    NSLog(@"info:%@",info.title);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.tabledata_name.count;
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RssCell";
    
    //NSMutableArray *tabledata = [[NSMutableArray alloc] initWithCapacity:0];
    
    RssTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.UserNameLabel.text = [[self.tabledata_name objectAtIndex:indexPath.row]capitalizedString];
    cell.RssTitle.text = @"An RSS and Atom web feed parser for iOS";
    cell.RssImageView.image = [UIImage imageNamed:@"Custom_image*2.png"];
    cell.RssAuther.text = @"shiyuhua";
    cell.RssDate.text = @"06-22 08:53";
    //cell.CommentTextLabel.text = [[self.tabledata_comment objectAtIndex:indexPath.row]capitalizedString];
    return cell;
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
