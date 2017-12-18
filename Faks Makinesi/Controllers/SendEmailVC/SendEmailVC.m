//
//  SendEmailVC.m
//  Fax
//
//  Created by Nguyen Tuan Cuong on 11/6/14.
//  Copyright (c) 2014 QTS. All rights reserved.
//

#import "SendEmailVC.h"
#import "UIImageView+AFNetworking.h"

@interface SendEmailVC ()

@end

@implementation SendEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imgBG setImageWithURL:[NSURL URLWithString:self.historyObj.imageUrl]];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)doSendEmail:(id)sender {
    
    NSArray *objectsToShare = @[self.imgBG.image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
