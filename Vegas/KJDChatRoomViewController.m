//
//  ViewController.m
//  Vegas

#import "KJDChatRoomViewController.h"

@interface KJDChatRoomViewController ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;

@property (nonatomic) CGRect keyBoardFrame;

@property(strong,nonatomic) NSMutableArray *messages;

@property(strong, nonatomic) NSMutableDictionary* contentToSend;

@end

@implementation KJDChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputTextField.delegate=self;
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
    
    self.contentToSend = [[NSMutableDictionary alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.navigationController setNavigationBarHidden:NO];
    [UIView commitAnimations];
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
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height+self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20, 0, 0, 0);
    
    if (moveUp){
        self.tableView.contentInset = inset;
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
    }else{
        self.tableView.contentInset = afterInset;
        superViewRect.origin.y += self.keyBoardFrame.size.height;
    }
    self.view.frame = superViewRect;
    [UIView commitAnimations];
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupViewsAndConstraints {
    [self setupNavigationBar];
    [self setupTableView];
    [self setupTextField];
    [self setupSendButton];
    [self setupMediaButton];
}

-(void)setupNavigationBar{
    self.navigationItem.title=self.chatRoom.firebaseRoomURL;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    
    [self.view addSubview:self.tableView];
    [self.view sendSubviewToBack:self.tableView.backgroundView];
    self.tableView.clipsToBounds = YES;
    [self.tableView registerClass:[KJDChatRoomTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.cell = [[KJDChatRoomTableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 57)];
    [self.tableView addSubview:self.cell];
    self.tableView.scrollEnabled = YES;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
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
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:1];
}

-(void)sendButtonNormal{
    if (![self.inputTextField.text isEqualToString:@""] && ![self.inputTextField.text isEqualToString:@" "]) {
        NSString *message = self.inputTextField.text;
        self.sendButton.titleLabel.textColor=[UIColor grayColor];
        [self.chatRoom.firebase setValue:@{@"user":self.user.name,
                                           @"message":message}];
        self.inputTextField.text = @"";
    }
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
}

- (void)setupSendButton{
    self.sendButton = [[UIButton alloc] init];
    [self.view addSubview:self.sendButton];
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    self.sendButton.layer.cornerRadius=10.0f;
    self.sendButton.layer.masksToBounds=YES;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:nil] forState:UIControlStateNormal];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(sendButtonNormal) forControlEvents:UIControlEventTouchUpInside];
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
    [self.view addSubview:self.mediaButton];
    [self.mediaButton addTarget:self
                         action:@selector(mediaButtonTapped)
               forControlEvents:UIControlEventTouchUpInside];
    self.mediaButton.backgroundColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
    [self.mediaButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    self.mediaButton.contentMode=UIViewContentModeCenter;
    self.mediaButton.layer.cornerRadius=10.0f;
    self.mediaButton.layer.masksToBounds=YES;
    [self.mediaButton addTarget:self action:@selector(mediaButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.mediaButton addTarget:self action:@selector(mediaButtonNormal) forControlEvents:UIControlEventTouchUpInside];
    
    self.mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mediaButtonTop = [NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *mediaButtonBottom =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.inputTextField
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
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
    self.mediaButton.backgroundColor=[UIColor colorWithRed:0.027 green:0.58 blue:0.373 alpha:1];
}

-(void)mediaButtonTapped{
    self.mediaButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:1];
    if ([self systemVersionLessThan8]){
        UIAlertView* mediaAlert = [[UIAlertView alloc] initWithTitle:@"Share something!" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a Picture or Video", @"Choose an existing Photo or Video", @"Share location", @"Send voice note", nil];
        [mediaAlert show];
    }else{
        UIAlertController* mediaAlert = [UIAlertController alertControllerWithTitle:@"Share something!" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"Take a Picture or Video"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){[self obtainImageFrom:UIImagePickerControllerSourceTypeCamera];
                                                          }];
        [mediaAlert addAction:takePhoto];
        UIAlertAction* chooseExistingPhoto = [UIAlertAction actionWithTitle:@"Choose an existing Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self obtainImageFrom:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        [mediaAlert addAction:chooseExistingPhoto];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [mediaAlert addAction:cancel];
        UIAlertAction* showLocation = [UIAlertAction actionWithTitle:@"Share Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self summonMap];
        }];
        [mediaAlert addAction:showLocation];
        [self presentViewController:mediaAlert animated:YES completion:^{
        }];
    }
}

- (void)setupTextField{
    self.inputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.inputTextField];
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
        
    }];
}

-(NSString *)imageToNSString:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(NSString*)videoToNSString:(NSURL*)video{
    NSData* videoData =[NSData dataWithContentsOfURL:video];
    return [videoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(UIImage *)stringToUIImage:(NSString *)string{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(void)stringToVideo:(NSString*)string{
    //may not work
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:string];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    //theoretically would play video.
    MPMoviePlayerController* videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: fileURL];
    
    
    //alternative - more to reproduce a video ; would need to know where a video is stored when saved.
    
    /*
     NSString *moviePath = [[info objectForKey:
     UIImagePickerControllerMediaURL] path];
     if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
     {
     UISaveVideoAtPathToSavedPhotosAlbum (moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
     }
     
     //for obtaining filePath, consider also:
     NSString *filepath = [[NSBundle mainBundle] pathForResource:@"vid" ofType:@"mp4"];
     
     */
}

-(BOOL)systemVersionLessThan8
{
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return deviceVersion < 8.0f;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"dictionnary = %@", info);
    NSString* mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    NSLog(@"mediaType = %@", mediaType);
    if([mediaType isEqualToString:@"public.image"]){
        UIImage *extractedPhoto = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSString *photoInString = [self imageToNSString:extractedPhoto];
        [self.contentToSend setObject:photoInString forKey:@"image"];
    }
    else if([mediaType isEqualToString:@"public.movie"]){
        NSLog(@" movie extract type: %@", [info[@"UIImagePickerControllerReferenceURL"] class]);
        NSLog(@" movie extract type: %@", [info[@"UIImagePickerControllerMediaURL"] class]);
        NSString* videoInString = [self videoToNSString:info[@"UIImagePickerControllerMediaURL"]];
        [self.contentToSend setObject:videoInString forKey:@"video"];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self obtainImageFrom:UIImagePickerControllerSourceTypeCamera];
    }else if (buttonIndex == 2){
        [self obtainImageFrom:UIImagePickerControllerSourceTypePhotoLibrary];
    }else if (buttonIndex == 3){
        [self summonMap];
    }
}

-(void)obtainImageFrom:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    NSArray *mediaTypesAllowed = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.mediaTypes = mediaTypesAllowed;
    
    //seems to be unnecessary
    //    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    //    {
    //        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, kUTTypeImage, nil];
    //    }
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:^{
                         
                     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //    self.cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //    self.cell.userMessageLabel.lineBreakMode=NSLineBreakByWordWrapping;
    //    self.cell.userMessageLabel.numberOfLines=0;
    //    self.cell.userInteractionEnabled=NO;
    //    self.cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines=0;
    cell.userInteractionEnabled=NO;
    if (![self.messages count]==0) {
        NSMutableDictionary *message=self.messages[indexPath.row];
        NSString *messageString=[NSString stringWithFormat:@"\n%@", message[@"message"]];
        if ([message[@"user"] isEqualToString:self.user.name]) {
            NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:self.user.name];
            [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
            NSAttributedString *atrStr = [[NSAttributedString alloc]initWithString:messageString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16]}];
            [muAtrStr appendAttributedString:atrStr];
            cell.textLabel.attributedText=muAtrStr;
            cell.backgroundColor=[UIColor clearColor];
            cell.textLabel.textAlignment=NSTextAlignmentRight;
            cell.textLabel.textAlignment=NSTextAlignmentRight;
            
            //            self.cell.usernameLabel.text=self.user.name;
            //            self.cell.userMessageLabel.text=message[@"message"];
            //            self.cell.usernameLabel.textAlignment=NSTextAlignmentRight;
            //            self.cell.userMessageLabel.textAlignment=NSTextAlignmentRight;
            
            return cell;
        }else{
            NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:self.user.name];
            [muAtrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14] range:NSMakeRange(0, [muAtrStr length])];
            NSAttributedString *atrStr = [[NSAttributedString alloc]initWithString:messageString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16]}];
            cell.backgroundColor=[UIColor clearColor];
            [muAtrStr appendAttributedString:atrStr];
            cell.textLabel.attributedText=muAtrStr;
            
            //            self.cell.usernameLabel.text=self.user.name;
            //            self.cell.userMessageLabel.text=message[@"message"];
            return cell;
        }
    }
    return cell;
}

@end
