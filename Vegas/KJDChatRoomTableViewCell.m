//
//  KJDChatRoomTableViewCell.m
//  Vegas
//
//  Created by Jan Roures Mintenig on 23/11/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import "KJDChatRoomTableViewCell.h"

@implementation KJDChatRoomTableViewCell

@synthesize nameLabel = _nameLabel;
@synthesize messageLabel = _messageLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 10)];
        [self.nameLabel sizeToFit];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        self.messageLabel =[[UILabel alloc]initWithFrame:CGRectMake(5, 25, 250, 10)];
        [self.messageLabel sizeToFit];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        [self addSubview:self.messageLabel];
        [self addSubview:self.nameLabel];
        [self sizeToFit];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
