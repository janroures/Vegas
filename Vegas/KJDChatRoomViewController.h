//
//  ViewController.h
//  Vegas

#import <UIKit/UIKit.h>
#import "KJDUser.h"
#import "KJDChatRoom.h"
#import "KJDChatRoomTableViewCellLeft.h"
#import "KJDChatRoomTableViewCellRight.h"
#import "KJDChatRoomImageCellLeft.h"
#import "KJDChatRoomImageCellRight.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KJDMapKitViewController.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class KJDUser;

@interface KJDChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(strong,nonatomic)KJDUser *user;
@property(strong,nonatomic)NSString *firebaseRoomURL;
@property(strong,nonatomic)NSString *firebaseURL;
@property(strong,nonatomic)KJDChatRoom *chatRoom;
-(void) sendMapImage:(UIImage*)map;

@property(strong,nonatomic)KJDChatRoomTableViewCellLeft *cell;

@end

