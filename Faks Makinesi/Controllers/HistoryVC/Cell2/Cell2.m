//
//  Cell2.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "Cell2.h"

@implementation Cell2

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)doClickImage:(id)sender {
    [self.delegate showImgFax:self.indexPath];
}

-(void) initCell2
{
    [self.lblTitle setFont:[UIFont fontWithName:FONT_NAME size:29]];
    for (UILabel *lb in self.arrLabels) {
        [lb setFont:[UIFont fontWithName:FONT_NAME size:24]];
    }
}
@end
