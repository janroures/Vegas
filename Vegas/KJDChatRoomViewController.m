//
//  ViewController.m
//  Vegas

#import "KJDChatRoomViewController.h"
#import <RNBlurModalView.h>

@interface KJDChatRoomViewController ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;

@property (strong, nonatomic) UIView *usernameView;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UIButton *doneButton;

@property (strong, nonatomic) NSLayoutConstraint *usernameViewTop;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewBottom;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewLeft;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewRight;

@property (nonatomic)CGRect keyBoardFrame;

@property (strong,nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableDictionary *contentToSend;
@property (strong, nonatomic) UIImage *extractedPhoto;

@end

@implementation KJDChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewsAndConstraints];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    backgroundImage.frame = frame;
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [self.chatRoom setupFirebaseWithCompletionBlock:^(BOOL completed) {
        if (completed) {
            self.messages = self.chatRoom.messages;
            self.user = self.chatRoom.user;
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self.tableView reloadData];
                if (![self.messages count] == 0) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //this line may be unecessary
    self.contentToSend = [[NSMutableDictionary alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.navigationController setNavigationBarHidden:NO];
    [UIView commitAnimations];
}

- (void)setupViewsAndConstraints {
    [self setupNavigationBar];
    [self setupTableView];
    //    [self setupUsernameView];
    [self setupTextField];
    [self setupSendButton];
    [self setupMediaButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
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
    CGRect superViewRect = self.view.frame;
    //    CGRect usernameViewRect = self.usernameView.frame;
    //    [self.view removeConstraints:@[self.usernameViewTop, self.usernameViewBottom]];
    
    //    NSLayoutConstraint *newTopConstraint = [NSLayoutConstraint constraintWithItem:self.usernameView
    //                                                                        attribute:NSLayoutAttributeTop
    //                                                                        relatedBy:NSLayoutRelationEqual
    //                                                                           toItem:self.view
    //                                                                        attribute:NSLayoutAttributeTop
    //                                                                       multiplier:1.0
    //                                                                         constant:self.keyBoardFrame.size.height];
    //
    //    NSLayoutConstraint *newBottomConstraint = [NSLayoutConstraint constraintWithItem:self.usernameView
    //                                                                           attribute:NSLayoutAttributeBottom
    //                                                                           relatedBy:NSLayoutRelationEqual
    //                                                                              toItem:self.view
    //                                                                           attribute:NSLayoutAttributeBottom
    //                                                                          multiplier:0.4
    //                                                                            constant:-(self.keyBoardFrame.size.height)];
    //
    //    NSLayoutConstraint *oldTopConstraint = [NSLayoutConstraint constraintWithItem:self.usernameView
    //                                                                        attribute:NSLayoutAttributeTop
    //                                                                        relatedBy:NSLayoutRelationEqual
    //                                                                           toItem:self.view
    //                                                                        attribute:NSLayoutAttributeTop
    //                                                                       multiplier:1.0
    //                                                                         constant:60.0];
    //
    //    NSLayoutConstraint *oldBottomConstraint = [NSLayoutConstraint constraintWithItem:self.usernameView
    //                                                                           attribute:NSLayoutAttributeBottom
    //                                                                           relatedBy:NSLayoutRelationEqual
    //                                                                              toItem:self.view
    //                                                                           attribute:NSLayoutAttributeBottom
    //                                                                          multiplier:0.4
    //                                                                            constant:0.0];
    
    
    
    
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height+self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    
    if (moveUp){
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0.3
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            //                            [self.view addConstraints:@[newTopConstraint, newBottomConstraint]];
                        }
                        completion:nil];
        
    }else{
        superViewRect.origin.y += self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0.3
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            //                            [self.view addConstraints:@[oldTopConstraint, oldBottomConstraint]];
                        }
                        completion:nil];
        self.tableView.contentInset = afterInset;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupNavigationBar{
    self.navigationItem.title=self.chatRoom.firebaseRoomURL;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleUsernameView)];
    //    [self.navigationItem setRightBarButtonItem:rightItem];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//-(void)setupUsernameView{
//    self.usernameView=[[UIView alloc]init];
//    UIColor *backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
//    self.usernameView.backgroundColor=backgroundColor;
//    self.usernameView.layer.cornerRadius=10;
//    self.usernameView.hidden=YES;
//    self.usernameView.translatesAutoresizingMaskIntoConstraints=NO;
//    [self.view addSubview:self.usernameView];
//
//    self.usernameViewTop=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                      attribute:NSLayoutAttributeTop
//                                                      relatedBy:NSLayoutRelationEqual
//                                                         toItem:self.view
//                                                      attribute:NSLayoutAttributeTop
//                                                     multiplier:1.0
//                                                       constant:60.0];
//
//    self.usernameViewBottom=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                         attribute:NSLayoutAttributeBottom
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:self.view
//                                                         attribute:NSLayoutAttributeBottom
//                                                        multiplier:0.4
//                                                          constant:0.0];
//
//    self.usernameViewLeft=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                       attribute:NSLayoutAttributeLeft
//                                                       relatedBy:NSLayoutRelationEqual
//                                                          toItem:self.view
//                                                       attribute:NSLayoutAttributeLeft
//                                                      multiplier:1.0
//                                                        constant:100.0];
//
//    self.usernameViewRight=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                        attribute:NSLayoutAttributeRight
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view
//                                                        attribute:NSLayoutAttributeRight
//                                                       multiplier:1.0
//                                                         constant:0.0];
//
//    [self.view addConstraints:@[self.usernameViewTop, self.usernameViewBottom, self.usernameViewLeft, self.usernameViewRight]];
//
//
//    self.usernameTextField=[[UITextField alloc]init];
//    self.usernameTextField.delegate=self;
//    self.usernameTextField.layer.borderWidth=1;
//    self.usernameTextField.layer.cornerRadius=7;
//    self.usernameTextField.backgroundColor=[UIColor whiteColor];
//    self.usernameTextField.textAlignment=NSTextAlignmentCenter;
//    self.usernameTextField.placeholder=@"Set username";
//    self.usernameTextField.translatesAutoresizingMaskIntoConstraints=NO;
//    [self.usernameView addSubview:self.usernameTextField];
//
//    NSLayoutConstraint *textFieldTop=[NSLayoutConstraint constraintWithItem:self.usernameTextField
//                                                                  attribute:NSLayoutAttributeTop
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:self.usernameView
//                                                                  attribute:NSLayoutAttributeTop
//                                                                 multiplier:1.0
//                                                                   constant:50.0];
//
//    NSLayoutConstraint *textFieldBottom=[NSLayoutConstraint constraintWithItem:self.usernameTextField
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:self.usernameView
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                    multiplier:1.0
//                                                                      constant:-80.0];
//
//    NSLayoutConstraint *textFieldLeft=[NSLayoutConstraint constraintWithItem:self.usernameTextField
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.usernameView
//                                                                   attribute:NSLayoutAttributeLeft
//                                                                  multiplier:1.0
//                                                                    constant:20.0];
//
//    NSLayoutConstraint *textFieldRight=[NSLayoutConstraint constraintWithItem:self.usernameTextField
//                                                                    attribute:NSLayoutAttributeRight
//                                                                    relatedBy:NSLayoutRelationEqual
//                                                                       toItem:self.usernameView
//                                                                    attribute:NSLayoutAttributeRight
//                                                                   multiplier:1.0
//                                                                     constant:-20.0];
//
//    [self.view addConstraints:@[textFieldTop, textFieldBottom, textFieldLeft, textFieldRight]];
//
//    self.doneButton=[[UIButton alloc]init];
//    [self.doneButton addTarget:self action:@selector(enterUserName) forControlEvents:UIControlEventTouchUpInside];
//    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
//    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.doneButton.layer.cornerRadius=7;
//    self.doneButton.translatesAutoresizingMaskIntoConstraints=NO;
//    [self.usernameView addSubview:self.doneButton];
//
//    NSLayoutConstraint *buttonTop=[NSLayoutConstraint constraintWithItem:self.doneButton
//                                                               attribute:NSLayoutAttributeTop
//                                                               relatedBy:NSLayoutRelationEqual
//                                                                  toItem:self.usernameTextField
//                                                               attribute:NSLayoutAttributeTop
//                                                              multiplier:1.0
//                                                                constant:50.0];
//
//    NSLayoutConstraint *buttonBottom=[NSLayoutConstraint constraintWithItem:self.doneButton
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:self.usernameView
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                 multiplier:1.0
//                                                                   constant:-30.0];
//
//    NSLayoutConstraint *buttonLeft=[NSLayoutConstraint constraintWithItem:self.doneButton
//                                                                attribute:NSLayoutAttributeLeft
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:self.usernameTextField
//                                                                attribute:NSLayoutAttributeLeft
//                                                               multiplier:1.0
//                                                                 constant:0.0];
//
//    NSLayoutConstraint *buttonRight=[NSLayoutConstraint constraintWithItem:self.doneButton
//                                                                 attribute:NSLayoutAttributeRight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.usernameTextField
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1.0
//                                                                  constant:0.0];
//
//    [self.view addConstraints:@[buttonTop, buttonBottom, buttonLeft, buttonRight]];
//}

-(void)enterUserName{
    if (![self.usernameTextField.text isEqualToString:@""]) {
        self.user.name=self.usernameTextField.text;
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=YES;
                        }
                        completion:nil];
        [self.tableView reloadData];
    }else{
        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:@"Username field is empty" message:@"Please insert a valid username"];
        [modal show];
    }
}

-(void)toggleUsernameView{
    if (self.usernameView.hidden) {
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=NO;
                        }
                        completion:nil];
    }else{
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=YES;
                        }
                        completion:nil];
    }
}

- (void)setupTableView{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    [self.view sendSubviewToBack:self.tableView.backgroundView];
    self.tableView.clipsToBounds=YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellLeft" bundle:nil] forCellReuseIdentifier:@"normalCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomTableViewCellRight" bundle:nil] forCellReuseIdentifier:@"normalCellRight"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellLeft" bundle:nil] forCellReuseIdentifier:@"imageCellLeft"];
    [self.tableView registerNib:[UINib nibWithNibName:@"KJDChatRoomImageCellRight" bundle:nil] forCellReuseIdentifier:@"imageCellRight"];
    self.tableView.scrollEnabled=YES;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:self.tableView];
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:50.0];
    
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

-(void)hideKeyboard{
    [self.view resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)sendButtonTapped{
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:1];
}

-(void)sendButtonNormal{
    if (![self.inputTextField.text isEqualToString:@""] && ![self.inputTextField.text isEqualToString:@" "]) {
        NSString *message = self.inputTextField.text;
        self.sendButton.titleLabel.textColor = [UIColor grayColor];
        [self.chatRoom.firebase setValue:@{@"user":self.user.name,
                                           @"message":message}];
        self.inputTextField.text = @"";
    }
    self.sendButton.backgroundColor = [UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    self.sendButton.titleLabel.textColor = [UIColor whiteColor];
}

- (void)setupSendButton{
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    self.sendButton.layer.cornerRadius=10.0f;
    self.sendButton.layer.masksToBounds=YES;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:nil] forState:UIControlStateNormal];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(sendButtonNormal) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sendButton];
    
    
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
                                                                         constant:-4.0];
    
    NSLayoutConstraint *sendButtonLeft = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:10.0];
    
    NSLayoutConstraint *sendButtonRight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.tableView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-10.0];
    
    [self.view addConstraints:@[sendButtonTop, sendButtonBottom, sendButtonLeft, sendButtonRight]];
}

-(void)setupMediaButton{
    self.mediaButton = [[UIButton alloc] init];
    [self.mediaButton addTarget:self
                         action:@selector(mediaButtonTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self.mediaButton setImage:[UIImage imageNamed:@"photography_camera"] forState:UIControlStateNormal];
    self.mediaButton.alpha=0.8;
    [self.mediaButton addTarget:self action:@selector(mediaButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.mediaButton addTarget:self action:@selector(mediaButtonNormal) forControlEvents:UIControlEventTouchUpInside];
    self.mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mediaButton];
    
    NSLayoutConstraint *mediaButtonTop = [NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:8.0];
    
    NSLayoutConstraint *mediaButtonBottom =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.inputTextField
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-8.0];
    
    NSLayoutConstraint *mediaButtonLeft =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:10.0];
    
    NSLayoutConstraint *mediaButtonRight =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:-10.0];
    [self.view addConstraints:@[mediaButtonTop, mediaButtonBottom, mediaButtonLeft, mediaButtonRight]];
}

-(void)mediaButtonNormal{
    self.mediaButton.alpha=0.8;
}

-(void)mediaButtonTapped{
    self.mediaButton.alpha=0.4;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)setupTextField{
    self.inputTextField = [[UITextField alloc] init];
    self.inputTextField.delegate=self;
    self.inputTextField.layer.cornerRadius=10.0f;
    self.inputTextField.layer.masksToBounds=YES;
    UIColor *borderColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    self.inputTextField.layer.borderColor=[borderColor CGColor];
    self.inputTextField.layer.borderWidth=1.5f;
    self.inputTextField.backgroundColor=[UIColor clearColor];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.inputTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.inputTextField setLeftView:spacerView];
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputTextField];
    
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
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-4.0];
    
    NSLayoutConstraint *textFieldLeft = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:45.0];
    
    NSLayoutConstraint *textFieldRight = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-70.0];
    
    [self.view addConstraints:@[textFieldTop, textFieldBottom, textFieldLeft, textFieldRight]];
}

-(void)summonMap
{
    KJDMapKitViewController* mapKitView = [[KJDMapKitViewController alloc] init];
    
    [self presentViewController:mapKitView animated:YES completion:^{
        NSLog(@"hh");
    }];
}

-(NSString *)imageToNSString:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1); //UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

//-(NSString*)videoToNSString:(NSURL*)video{
//    NSData* videoData =[NSData dataWithContentsOfURL:video];
//    return [videoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//}

-(UIImage *)stringToUIImage:(NSString *)string{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

//-(void)stringToVideo:(NSString*)string{
//    //may not work
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:string];
//
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
//
//    //theoretically would play video.
//    MPMoviePlayerController* videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: fileURL];
//
//
//    //alternative - more to reproduce a video ; would need to know where a video is stored when saved.
//
//    /*
//     NSString *moviePath = [[info objectForKey:
//     UIImagePickerControllerMediaURL] path];
//     if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
//     {
//     UISaveVideoAtPathToSavedPhotosAlbum (moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//     }
//
//     //for obtaining filePath, consider also:
//     NSString *filepath = [[NSBundle mainBundle] pathForResource:@"vid" ofType:@"mp4"];
//
//     */
//}

-(BOOL)systemVersionLessThan8
{
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return deviceVersion < 8.0f;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"Finsihed picking");
    NSString* mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:@"public.image"]){
        self.extractedPhoto = info[@"UIImagePickerControllerOriginalImage"];
        
        NSOperationQueue *imageSendQueue = [[NSOperationQueue alloc] init];
        [imageSendQueue addOperationWithBlock:^{
            NSString *photoInString = [self imageToNSString:self.extractedPhoto];
            [self.chatRoom.firebase setValue:@{@"user":self.user.name,
                                               @"image":photoInString}];
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

//-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(buttonIndex == 1){
//        [self obtainImageFrom:UIImagePickerControllerSourceTypeCamera];
//    }else if (buttonIndex == 2){
//        [self obtainImageFrom:UIImagePickerControllerSourceTypePhotoLibrary];
//    }else if (buttonIndex == 3){
//        [self summonMap];
//    }
//}

//-(void)obtainImageFrom:(UIImagePickerControllerSourceType)sourceType{
//    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.sourceType = sourceType;
//    NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    imagePicker.mediaTypes = mediaTypesAllowed;
//
//    //seems to be unnecessary
//    //    if (sourceType == UIImagePickerControllerSourceTypeCamera)
//    //    {
//    //        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, kUTTypeImage, nil];
//    //    }
//
//    imagePicker.delegate = self;
//    [self presentViewController:imagePicker
//                       animated:YES
//                     completion:^{
//
//                     }];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.messages count]==0) {
        NSMutableDictionary *message=self.messages[indexPath.row];
        if ([message objectForKey:@"message"]!=nil) {
            NSDictionary *message=self.messages[indexPath.row];
            NSString *yourText = message[@"message"]; // or however you are getting the text
            return 51 + [self heightForText:yourText];
        }else{
            return 180;
        }
    }
    return 0;
}

-(CGFloat)heightForText:(NSString *)text
{
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.messages count]==0) {
        NSMutableDictionary *message=self.messages[indexPath.row];
        //check if the message contains a string message, if not the message contains an image (as string)
        if ([message objectForKey:@"message"]!=nil) {
            NSString *messageString=[NSString stringWithFormat:@"\n%@", message[@"message"]];
            //if the sender is the user, put username and image to the right, if not to the left
            if ([message[@"user"] isEqualToString:self.user.name]) {
                KJDChatRoomTableViewCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"normalCellRight"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:self.user.name];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
                
                rightCell.usernameLabel.attributedText = muAtrStr;
                rightCell.usernameLabel.textAlignment = NSTextAlignmentRight;
                rightCell.backgroundColor=[UIColor clearColor];
                rightCell.userMessageTextView.text=messageString;
                rightCell.userMessageTextView.textAlignment=NSTextAlignmentRight;
                rightCell.userMessageTextView.backgroundColor=[UIColor clearColor];
                [rightCell.userMessageTextView sizeToFit];
                [rightCell.userMessageTextView layoutIfNeeded];
                
                return rightCell;
            }else{
                KJDChatRoomTableViewCellLeft *leftCell=[tableView dequeueReusableCellWithIdentifier:@"normalCellLeft"];
                NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:message[@"user"]];
                [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
                leftCell.backgroundColor=[UIColor clearColor];
                leftCell.usernameLabel.attributedText=muAtrStr;
                leftCell.userMessageTextView.text=messageString;
                leftCell.userMessageTextView.backgroundColor=[UIColor clearColor];
                [leftCell.userMessageTextView sizeToFit];
                [leftCell.userMessageTextView layoutIfNeeded];
                
                return leftCell;
            }
        }else{
            if ([message objectForKey:@"image"]!=nil) {
                NSString *imageString=message[@"image"];
                UIImage *image=[self stringToUIImage:imageString];
                
                if ([message[@"user"] isEqualToString:self.user.name]) {
                    KJDChatRoomImageCellRight *rightCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellRight"];
                    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:message[@"user"]];
                    [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
                    
                    rightCell.usernameLabel.attributedText=muAtrStr;
                    rightCell.backgroundColor=[UIColor clearColor];
                    rightCell.mediaImageView.image=image;
                    
                    return rightCell;
                }else{
                    KJDChatRoomImageCellRight *leftCell=[tableView dequeueReusableCellWithIdentifier:@"imageCellLeft"];
                    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:message[@"user"]];
                    [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
                    
                    leftCell.usernameLabel.attributedText=muAtrStr;
                    leftCell.backgroundColor=[UIColor clearColor];
                    leftCell.mediaImageView.image=image;
                    
                    return leftCell;
                }
            }
        }
    }
    return nil;
}

@end

