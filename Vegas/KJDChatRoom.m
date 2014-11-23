//
//  KJDChatRoom.m
//  Vegas

#import "KJDChatRoom.h"
#import <Firebase/Firebase.h>
#import "KJDChatRoomViewController.h"


@implementation KJDChatRoom

-(instancetype)initWithUser:(KJDUser *)user{
    self=[super init];
    if (self) {
        _user=user;
        _messages=[[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)init{
    return [self initWithUser:self.user];
}

-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock{
    NSMutableArray *messagesArray=[[NSMutableArray alloc]init];
    if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
        [messagesArray addObject:snapshot.value];
    }else if ([snapshot.value isKindOfClass:[NSString class]]){
        NSLog(@"%@", snapshot.value);
        [messagesArray addObject:snapshot.value];
    }
    completionBlock(messagesArray);
}

- (void)setupFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock{
    self.firebaseURL = [NSString stringWithFormat:@"https://boiling-torch-9946.firebaseio.com/%@", self.firebaseRoomURL];
    self.firebase = [[Firebase alloc] initWithUrl:self.firebaseURL];
    [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self fetchMessagesFromCloud:snapshot withBlock:^void(NSMutableArray *messages) {
            [self.messages addObjectsFromArray:messages];
            completionBlock(YES);
        }];
    }];
}

@end
