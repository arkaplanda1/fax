//
//  ConfirmPictureVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmPictureVC : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) UIImage *imgCapture;
- (IBAction)doBack:(id)sender;
- (IBAction)doTick:(id)sender;

@end
