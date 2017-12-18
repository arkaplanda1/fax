//
//  HistoryVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "HistoryVC.h"
#import "Cell1.h"
#import "Cell2.h"
#import "HistoryObj.h"
#import "CreditVC.h"
#import "SendEmailVC.h"
#import "UIImageResizing.h"
#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSON.h"
#import "CommonHelper.h"
#import "NSFileManager+Helper.h"
#import "UIImageView+AFNetworking.h"

#define IS_IPHONE_4_SCREEN() ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
@interface HistoryVC ()<UITableViewDataSource, UITableViewDelegate,Cell2Delegate>
{
    NSMutableArray *_arrHistory;
}
@end

@implementation HistoryVC

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

    [[CommonHelper appDelegate] setTabbarHidden:NO];

    [self.navigationController setNavigationBarHidden:YES];

    _arrHistory = [[NSMutableArray alloc] init];
    [self callWSCount];
//    _arrHistory = [FakDAO getAllTransaction];
    self.lblCredit.text = NSLocalizedString(@"TXT_CREDITS",nil);
    self.lblCreditCount.text = [CommonHelper.appDelegate GetData:NUMBER_FAX];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCredit_pressed:(UIButton *)sender {
    CreditVC *creditVc =[[CreditVC alloc] init];
    [self.navigationController pushViewController:creditVc animated:YES];
}

- (IBAction)btnDelete_pressed:(UIButton *)sender {
    [[NetworkService createInstance] deleteFax:sender.tag+1 callback:^{
        [self callWSCount];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryObj *obj = [_arrHistory objectAtIndex:indexPath.row];
    if (obj.isSelect) {
        return 174;
    }
    return 55;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrHistory.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryObj *obj1 = [_arrHistory objectAtIndex:indexPath.row];
    if (obj1.isSelect) {
        Cell2 *currentCell=(Cell2 *)[self.tblHistory dequeueReusableCellWithIdentifier:@"Cell2"];
        if (currentCell == nil)
        {
            currentCell = [[[NSBundle mainBundle] loadNibNamed:@"Cell2" owner:self options:nil] objectAtIndex:0];
        }
        [currentCell initCell2];
        currentCell.delegate = self;
        currentCell.indexPath = indexPath.row;
         currentCell.lblTitle.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"TXT_FAX",nil),indexPath.row+1];
         currentCell.lblThumb.text = NSLocalizedString(@"TXT_FAX",nil);
        currentCell.lbl1.text = [NSString stringWithFormat:@"- %@: %@",NSLocalizedString(@"TXT_SENT",nil),obj1.date];
        currentCell.lbl2.text = [NSString stringWithFormat:@"- %@: %@",NSLocalizedString(@"TXT_DURATION",nil),obj1.duration];
        currentCell.lbl3.text = [NSString stringWithFormat:@"- %@: %@",NSLocalizedString(@"TXT_FAX_PHONE",nil),obj1.faxnumber];
        currentCell.lbl4.text = [NSString stringWithFormat:@"- %@: %@",NSLocalizedString(@"TXT_STATUS",nil),obj1.status];
        [currentCell.imgThumbnail setImageWithURL:[NSURL URLWithString:obj1.imageUrl]];
        currentCell.backgroundColor=[UIColor clearColor];
        currentCell.btnDelete.tag = indexPath.row;
        [currentCell.btnDelete addTarget:self action:@selector(btnDelete_pressed:) forControlEvents:UIControlEventTouchUpInside];
        return currentCell;

    }
    else
    {
        Cell1 *currentCell=(Cell1 *)[self.tblHistory dequeueReusableCellWithIdentifier:@"Cell1"];
        if (currentCell == nil)
        {
            currentCell = [[[NSBundle mainBundle] loadNibNamed:@"Cell1" owner:self options:nil] objectAtIndex:0];
            
        }
        [currentCell initCell1];
        currentCell.btnDelete.tag = indexPath.row;
        [currentCell.btnDelete addTarget:self action:@selector(btnDelete_pressed:) forControlEvents:UIControlEventTouchUpInside];
        currentCell.lblTitle.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"TXT_FAX",nil),indexPath.row+1];
         currentCell.backgroundColor=[UIColor clearColor];
        return currentCell;

    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![CommonHelper connectedInternet]) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
        return;
    }
    HistoryObj *obj = [_arrHistory objectAtIndex:indexPath.row];
    if (obj.isSelect) {
        obj.isSelect =  NO;
    }
    else
    {
        obj.isSelect =  YES;
    }
    if (obj.isDownload) {
        [self.tblHistory reloadData];
    }
    else
    {
         [self callWSHisory:indexPath.row];
    }
    //[self.tblHistory reloadData];
}

-(void)callWSHisory:(int)index
{    
    [[NetworkService createInstance] getFaxDetail:index+1 callback:^(HistoryObj *detail) {
        detail.isSelect = YES;
        detail.isDownload = YES;
        [_arrHistory replaceObjectAtIndex:index withObject:detail];
        [self.tblHistory reloadData];
    }];
}


-(void) callWSCount
{
    _arrHistory = [[NSMutableArray alloc] init];
    [self.tblHistory reloadData];

    [[NetworkService createInstance]getFaxCount:^(int count) {
        for (int i=0; i<count; i++) {
            HistoryObj *obj = [HistoryObj new];
            [_arrHistory addObject:obj];
        }
        [self.tblHistory reloadData];
    }];
}

-(void) showImgFax:(int)index
{
    SendEmailVC *emailVC =[[SendEmailVC alloc] init];
    emailVC.historyObj = [_arrHistory objectAtIndex:index];
    [self presentViewController:emailVC animated:YES completion:^{
        
    }];
}
@end

