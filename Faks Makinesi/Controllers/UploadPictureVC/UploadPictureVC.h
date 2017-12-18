//
//  UploadPictureVC.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadPictureVC : UIViewController
@property(nonatomic,retain) UIImage *imgUpload;
@property (strong, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UILabel *lblFaxPhone;
@property (strong, nonatomic) IBOutlet UILabel *lblNote;
@property (strong, nonatomic) IBOutlet UIView *subPhone;
- (IBAction)doBack:(id)sender;
- (IBAction)doTick:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *subProgress;
@property (strong, nonatomic) IBOutlet UITextField *txfPhone;
@property (strong, nonatomic) IBOutlet UIView *subAction;
@property (strong, nonatomic) IBOutlet UILabel *lblConvert;
@property (strong, nonatomic) IBOutlet UILabel *lblPercent;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UIView *childProgress;

@end
