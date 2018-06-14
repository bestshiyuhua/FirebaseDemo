
//
//  CommentViewController.m
//  FirebaseUIDemo
//
//  Created by Yuhua Shi on 2018/06/08.
//  Copyright © 2018年 Yuhua Shi. All rights reserved.
//

#import "CommentViewController.h"
#import "CustomCell.h"
@import Firebase;

@interface CommentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, readwrite) FIRFirestore *db;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib
    //预计高度为430--即是cell高度
    self.tableView.estimatedRowHeight = 40.0f;
    //自适应高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //[self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.db = [FIRFirestore firestore];
}

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.mylabel.text = @"SHI";
    cell.myImageView.image = [UIImage imageNamed:@"Custom_image*2.png"];
    cell.mylabel2.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)submitBtn:(id)sender {
    [[[self.db collectionWithPath:@"users"] documentWithPath:_nameTextField.text] setData:@{
    @"name": _nameTextField.text,
    @"born": _bornTextField.text
    } completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error writing document: %@", error);
        } else {
            NSLog(@"Document successfully written!");
        }
    }];
}

- (IBAction)queryBtn:(id)sender {
    [[[self.db collectionWithPath:@"users"] queryWhereField:@"name" isEqualTo:_nameQueryTextField.text]
     getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
         if (error != nil) {
             NSLog(@"Error getting documents: %@", error);
         } else {
             for (FIRDocumentSnapshot *document in snapshot.documents) {
                 NSLog(@"%@ => %@", document.documentID, document.data);
                 _bornQueryTextField.text = [document.data objectForKey:@"born"];
                 NSLog(@"%@ ",[document.data objectForKey:@"born"]);
             }
         }
     }];
}
@end
