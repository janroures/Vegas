//
//  ViewController.h
//  Vegas

#import <UIKit/UIKit.h>
#import "KJDUser.h"

@class KJDUser;

@interface KJDChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) KJDUser *user;
@property (strong, nonatomic) NSString *firebaseRoomURL;
@property (strong,nonatomic)NSString *firebaseURL;

@end

