//
//  Cell1.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell1 : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
-(void) initCell1;
@end
