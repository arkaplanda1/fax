//
//  Cell1.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "Cell1.h"

@implementation Cell1

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initCell1
{
    [self.lblTitle setFont:[UIFont fontWithName:FONT_NAME size:29]];
}
@end
