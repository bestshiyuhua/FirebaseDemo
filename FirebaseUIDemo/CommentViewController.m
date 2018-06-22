
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *CommentView;
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
    //监听键盘
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //datasource & delegate
    self.CommentView.dataSource = self;
    self.CommentView.delegate = self;
    //预计高度为430--即是cell高度
    self.CommentView.estimatedRowHeight = 40.0f;
    //自适应高度
    self.CommentView.rowHeight = UITableViewAutomaticDimension;
    //[self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:@"CellIdentifier"];
    //firestroe初始化
    self.db = [FIRFirestore firestore];
    //分割线长度(top,left,bottom,right)
    self.CommentView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 15);
}

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.tabledata_name.count;
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";

    //NSMutableArray *tabledata = [[NSMutableArray alloc] initWithCapacity:0];
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.UserNameLabel.text = [[self.tabledata_name objectAtIndex:indexPath.row]capitalizedString];
    cell.UserNameLabel.text = @"shiyuhua";
    cell.UserImageView.image = [UIImage imageNamed:@"Custom_image*2.png"];
    cell.CommentTextLabel.text = @"222222222222222222222";
    //cell.CommentTextLabel.text = [[self.tabledata_comment objectAtIndex:indexPath.row]capitalizedString];
    return cell;
}

- (IBAction)submitBtn:(id)sender {
    FIRUser *user = [FIRAuth auth].currentUser;
    //submit comment to firestore
    [[[self.db collectionWithPath:@"users"] documentWithPath:user.displayName] setData:@{
    //@"name": _nameTextField.text,
    @"uid": user.uid,
    @"name": user.displayName,
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
            [self.CommentView reloadData];
        } else {
            NSLog(@"Document does not exist");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//键盘弹出
-(void)keyboardWillChangeFrame:(NSNotification*)notification{
    
    NSLog(@"notification-info:%@",notification.userInfo);
    
    //获取键盘弹起时y值
    CGFloat keyboardY=[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    //改变底部约束
    self.bottomConstraint.constant=[UIScreen mainScreen].bounds.size.height-keyboardY;
    //获取键盘弹起时间
    CGFloat duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration: duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    
}
-(void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

@end
