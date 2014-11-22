//
//  ViewController.m
//  ChatCodev2
//
//  Created by DANNY WU on 11/12/14.
//  Copyright (c) 2014 DANNY WU. All rights reserved.
//

#import "KJDChatRoomViewController.h"
#import <Firebase/Firebase.h>

@interface KJDChatRoomViewController ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong,nonatomic) UILabel *label;

@property (strong, nonatomic) UIButton *sendButton;
@property(strong,nonatomic)Firebase *firebase;
@property(nonatomic)CGRect keyBoardFrame;

@property(strong,nonatomic)NSMutableArray *messages;

@end

@implementation KJDChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputTextField.delegate=self;
    self.messages=[[NSMutableArray alloc]init];
    [self setupFirebase];
    [self setupViewsAndConstraints];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)setupFirebase{
    self.firebaseURL = [NSString stringWithFormat:@"https://boiling-torch-9946.firebaseio.com/%@", self.firebaseRoomURL];
    self.firebase = [[Firebase alloc] initWithUrl:self.firebaseURL];
    
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self fetchMessagesFromCloud:snapshot withBlock:^{
            [self.tableView reloadData];
        }];
    }];
}

-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)())completionBlock{
    if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
        [self.messages addObject:snapshot.value[@"message"]];
    }else if ([snapshot.value isKindOfClass:[NSString class]]){
        NSLog(@"%@", snapshot.value);
        [self.messages addObject:snapshot.value];
    }
    completionBlock();
}

-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyBoardFrame = [keyboardFrameBegin CGRectValue];
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification{
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)moveUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect superViewRect = self.view.frame;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    
    if (moveUp){
        self.tableView.contentInset = inset;
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
//        rect.size.height += self.keyBoardFrame.size.height;
    }else{
        self.tableView.contentInset = afterInset;
        superViewRect.origin.y += self.keyBoardFrame.size.height;
//        rect.size.height -= self.keyBoardFrame.size.height;
    }
    self.view.frame = superViewRect;
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViewsAndConstraints {
    [self setupNavigationBar];
    [self setupTableView];
    [self setupTextField];
    [self setupSendButton];
}

-(void)setupNavigationBar{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar.topItem setTitle:self.firebaseRoomURL];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:self.navigationController.navigationBar.frame.size.height+20.0];
    
    NSLayoutConstraint *tableViewBottom = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-40.0];
    
    NSLayoutConstraint *tableViewWidth = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    [self.view addConstraints:@[tableViewTop, tableViewBottom, tableViewWidth]];
}

- (void)sendButtonTapped{
    NSLog(@"Button Tapped");
    NSString *message = self.inputTextField.text;
    [self.firebase setValue:message];
    self.inputTextField.text = @"";
    [self.view endEditing:YES];
}

- (void)setupSendButton{
    self.sendButton = [[UIButton alloc] init];
    [self.view addSubview:self.sendButton];
    self.sendButton.backgroundColor = [UIColor blueColor];
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:nil] forState:UIControlStateNormal];
    
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *sendButtonTop = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    NSLayoutConstraint *sendButtonBottom = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    NSLayoutConstraint *sendButtonLeft = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *sendButtonRight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.tableView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0.0];
    
    [self.view addConstraints:@[sendButtonTop, sendButtonBottom, sendButtonLeft, sendButtonRight]];
}

- (void)setupTextField
{
    self.inputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.inputTextField];
    self.inputTextField.backgroundColor = [UIColor greenColor];
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *textFieldTop = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.tableView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    NSLayoutConstraint *textFieldBottom = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.tableView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:40.0];
    
    NSLayoutConstraint *textFieldLeft = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    NSLayoutConstraint *textFieldRight = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-80.0];
    
    [self.view addConstraints:@[textFieldTop, textFieldBottom, textFieldLeft, textFieldRight]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //test data
    
    return 15;
    
//    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    //test data
    
    cell.textLabel.text=[NSString stringWithFormat:@"asdasdasd %ld", (long)indexPath.row];
    
//    if (![self.messages count]==0) {
//        NSString *message=self.messages[indexPath.row];
//        cell.textLabel.text=message;
//    }
    
    return cell;
}

@end
