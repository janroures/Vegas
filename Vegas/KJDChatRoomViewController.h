//
//  ViewController.h
//  ChatCodev2
//
//  Created by DANNY WU on 11/12/14.
//  Copyright (c) 2014 DANNY WU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJDUser.h"

@class KJDUser;

@interface KJDChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) KJDUser *user;
@property (strong, nonatomic) NSString *firebaseRoomURL;
@property (strong,nonatomic)NSString *firebaseURL;

@end

