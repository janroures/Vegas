//
//  KJDUser.m
//  Vegas

#import "KJDUser.h"

@implementation KJDUser

NSString *const lettersAndNumbersString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *)createRandomUsername{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:15];
    for (NSUInteger i = 0; i < 15; i++) {
        u_int32_t randomNumber = arc4random() % [lettersAndNumbersString length];
        unichar randomCharacter = [lettersAndNumbersString characterAtIndex:randomNumber];
        [randomString appendFormat:@"%C", randomCharacter];
    }
    return randomString;
}

-(instancetype)init{
    return [self initWithRandomName];
}

-(instancetype)initWithRandomName{
    self=[super init];
    if (self) {
        _name=[self createRandomUsername];
    }
    return self;
}

@end
