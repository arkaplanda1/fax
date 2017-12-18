//
//  Cell2.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Cell2Delegate;
@interface Cell2 : UITableViewCell
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabels;
@property (strong, nonatomic) IBOutlet UILabel *lbl1;
@property (strong, nonatomic) IBOutlet UILabel *lbl2;
@property (strong, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property(nonatomic,assign) int indexPath;
@property (weak, nonatomic) IBOutlet UILabel *lblThumb;
@property(nonatomic,retain) id<Cell2Delegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnail;
- (IBAction)doClickImage:(id)sender;
-(void) initCell2;
@end

@protocol Cell2Delegate <NSObject>

-(void) showImgFax:(int) index;

@end
