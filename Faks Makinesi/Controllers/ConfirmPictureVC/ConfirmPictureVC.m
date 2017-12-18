//
//  ConfirmPictureVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "ConfirmPictureVC.h"
#import "UploadPictureVC.h"
@interface ConfirmPictureVC ()

@end

@implementation ConfirmPictureVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imgBG.image = [CommonHelper applyBWFilter:self.imgCapture];
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = self.imgBG.image.size.width / self.scrollView.frame.size.width;
    self.scrollView.contentSize = self.imgBG.frame.size;
    // Do any additional setup after loading the view from its nib.
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgBG;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doTick:(id)sender {
    UploadPictureVC *uploadPicture =[[UploadPictureVC alloc] init];
    uploadPicture.imgUpload = self.imgCapture;
    [self.navigationController pushViewController:uploadPicture animated:NO];
}
@end
