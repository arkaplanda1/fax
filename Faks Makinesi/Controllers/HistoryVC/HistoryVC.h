//
//  HistoryVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryVC : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCount;
@property (strong, nonatomic) IBOutlet UITableView *tblHistory;

@end
