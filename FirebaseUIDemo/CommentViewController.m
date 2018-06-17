
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
@property (nonatomic,readwrite) NSMutableArray *tabledata_name;
@property (nonatomic,readwrite) NSMutableArray *tabledata_comment;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@end

@implementation CommentViewController

-(void)loadView{
    [super loadView];
    self.tabledata_name = [[NSMutableArray alloc] initWithCapacity:0];
    self.tabledata_comment = [[NSMutableArray alloc] initWithCapacity:0];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // [START auth_listener]
    self.handle = [[FIRAuth auth]
                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                   }];
    // [END auth_listener]
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // [START remove_auth_listener]
    [[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
    // [END remove_auth_listener]
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    //[self.tabledata addObject:@""];
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
    return self.tabledata_name.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";

    //NSMutableArray *tabledata = [[NSMutableArray alloc] initWithCapacity:0];
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.mylabel.text = self.tabledata_name[0];
    cell.mylabel.text = [[self.tabledata_name objectAtIndex:indexPath.row]capitalizedString];
    cell.myImageView.image = [UIImage imageNamed:@"Custom_image*2.png"];
    //cell.mylabel2.text = self.tabledata_comment[0];
    cell.mylabel2.text = [[self.tabledata_comment objectAtIndex:indexPath.row]capitalizedString];
    return cell;
}

- (IBAction)submitBtn:(id)sender {
    FIRUser *user = [FIRAuth auth].currentUser;
    //submit comment to firestore
    [[[self.db collectionWithPath:@"users"] documentWithPath:user.displayName] setData:@{
    //@"name": _nameTextField.text,
    @"uid": user.uid,
    @"name": user.displayName,
    @"comment": _bornTextField.text
    } completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error writing document: %@", error);
        } else {
            NSLog(@"Document successfully written!");
        }
    }];
    //reload tableview data
    FIRDocumentReference *docRef =
    [[self.db collectionWithPath:@"users"] documentWithPath:user.displayName];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot.exists) {
            // Document data may be nil if the document exists but has no keys or values.
            NSLog(@"Document data: %@", snapshot.data);
            NSString *name = [snapshot.data objectForKey:@"name"];
            //NSLog(@"name:%@",name);
            [self.tabledata_name addObject:name];
            NSString *comment = [snapshot.data objectForKey:@"comment"];
            [self.tabledata_comment addObject:comment];
            NSLog(@"name:%@,comment:%@",name,comment);
            [self.tableView reloadData];
        } else {
            NSLog(@"Document does not exist");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
