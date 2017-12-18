//
//  UploadPictureVC.m
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import "UploadPictureVC.h"
#import "CustomKeyboard.h"
#import "ImageProcessor.h"
#import "UIImage+OrientationFix.h"
#import <CFNetwork/CFNetwork.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "JSON.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NSFileManager+Helper.h"
#import "HistoryVC.h"
#import "ActionSheetPicker.h"

@interface UploadPictureVC ()<UITextFieldDelegate,CustomKeyboardDelegate,ImageProcessorDelegate, UIAlertViewDelegate>
{
    CustomKeyboard *customkeyboard;
    int _indexKeyboard;
    UIImage *imgWorking;
    NSTimer *timer;
    NSString *_strPhone;
    NSString *_strImage;
    NSData *_dataIMG;
    NSString *_url;
    NSArray *countries;
    NSInteger selectedCountry;
}
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@end

@implementation UploadPictureVC

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
    customkeyboard = [[CustomKeyboard alloc] init];
    customkeyboard.delegate = self;
    self.imgBG.image = [CommonHelper applyBWFilter:self.imgUpload];
    //[CommonHelper showBusyView];
    //timer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monochrome) userInfo:nil repeats:YES];
    self.subAction.hidden = NO;
    self.subPhone.hidden = NO;
    
    [[NetworkService createInstance] getCountryCode:^(int code) {
        if (code == 0) {
            [self.btnCountryCode setTitle:@"" forState:UIControlStateNormal];
        }else{
            [self.btnCountryCode setTitle:[@"+" stringByAppendingFormat:@"%d",code] forState:UIControlStateNormal];
        }
    }];
    
    [[NetworkService createInstance] getCountries:^(NSArray *contries) {
        NSLog(@"%@", contries);
        countries = contries;
    }];

    self.lblNote.text = NSLocalizedString(@"TXT_COUNTRY_CODE",nil);
    self.lblFaxPhone.text = NSLocalizedString(@"TXT_FAX_PHONE",nil);
    self.lblConvert.text = NSLocalizedString(@"TXT_WAIT",nil);

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 20)];
    self.txfPhone.leftView = paddingView;
    self.txfPhone.leftViewMode = UITextFieldViewModeAlways;
    /*
    if (IS_IPAD) {
        [self.lblNote setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT_IPAD]];
        [self.lblConvert setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT_IPAD]];
        [self.lblPercent setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT_IPAD]];
        [self.btnSend.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT_IPAD]];
        [self.btnSend setTitle:NSLocalizedString(@"TXT_SEND", nil) forState:UIControlStateNormal];
        [self.txfPhone setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT_IPAD]];
    }
    else
    {
        [self.lblNote setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT]];
        [self.lblConvert setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT]];
        [self.lblPercent setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT]];
        [self.btnSend.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT]];
        [self.btnSend setTitle:NSLocalizedString(@"TXT_SEND", nil) forState:UIControlStateNormal];
         [self.txfPhone setFont:[UIFont fontWithName:FONT_NAME size:SIZE_TEXT]];
    }
     */
    
    NSLog(@"%f----%f",self.imgUpload.size.width,self.imgUpload.size.height);
    
    CALayer *l = [self.childProgress layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:5.0f];
    [l setBorderWidth:1.0f];
    [l setBorderColor:[UIColor clearColor].CGColor];
    self.childProgress.clipsToBounds = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) monochrome
{
    [timer invalidate];
    timer = nil;
    //UIImage * fixedImage = [self.imgUpload imageWithFixedOrientation];
    //self.imgBG.image  =[self applyFilter:fixedImage];
    self.imgBG.image = self.imgUpload;
    [CommonHelper hideBusyView];
    self.subAction.hidden = NO;
    self.subPhone.hidden = NO;
}

- (void)setupWithImage:(UIImage*)image {
    UIImage * fixedImage = [image imageWithFixedOrientation];
    self.imgBG.image = [self applyFilter:fixedImage];
    [CommonHelper hideBusyView];
    
    /*imgWorking = fixedImage;
    
    // Commence with processing!
    [ImageProcessor sharedProcessor].delegate = self;
    [[ImageProcessor sharedProcessor] processImage:fixedImage];*/
}

- (UIImage*)applyFilter:(UIImage *)image
{
    return [self filteredImage:image withFilterName:@"CIPhotoEffectMono"];
}

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    if([filterName isEqualToString:@"CLDefaultEmptyFilter"]){
        return image;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        // parameters for CIVignetteEffect
        CGFloat R = MIN(image.size.width, image.size.height)/2;
        CIVector *vct = [[CIVector alloc] initWithX:image.size.width/2 Y:image.size.height/2];
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}



#pragma mark - Protocol Conformance

#pragma mark - ImageProcessorDelegate

- (void)imageProcessorFinishedProcessingWithImage:(UIImage *)outputImage {
    [CommonHelper hideBusyView];
    self.imgBG.image = outputImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)btnCountryCode_pressed:(UIButton *)sender {
    NSMutableArray *arData = [NSMutableArray new];
    for (NSDictionary *dic in countries) {
        [arData addObject:[@"" stringByAppendingFormat:@"%@ %@",[[dic valueForKey:@"name"] uppercaseString],[dic valueForKey:@"code"]]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:arData initialSelection:selectedCountry doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSDictionary *dic = countries[selectedIndex];
        [self.btnCountryCode setTitle:[dic valueForKey:@"code"] forState:UIControlStateNormal];
        selectedCountry = selectedIndex;
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}

- (IBAction)doTick:(id)sender {
    [self validateNumber];
    return;
    
    NSString *strPhone =[self stringByTrimString:self.txfPhone.text];
    NSString *strValue;
    NSRange replaceRange = [strPhone rangeOfString:@"("];
    if (replaceRange.location != NSNotFound){
        NSString* result = [strPhone stringByReplacingCharactersInRange:replaceRange withString:@""];
        strValue =result;
    }
    
    NSString *strPhone1 =strValue;
    NSRange replaceRange1 = [strPhone1 rangeOfString:@")"];
    if (replaceRange1.location != NSNotFound){
        NSString* result1 = [strPhone1 stringByReplacingCharactersInRange:replaceRange1 withString:@""];
        strValue = result1;
    }
    
    if (strValue.length ==0 ||  strValue.length <10) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_INVALID_FAX",nil)];
    }
    else
    {
        if (![CommonHelper connectedInternet]) {
            [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
            return;
        }
        _strPhone =[NSString stringWithFormat:@"+90%@",strValue];
        NSString *subStr = [strValue substringWithRange:NSMakeRange(0, 1)];
        NSLog(@"SUb str %@",subStr);
        if ([subStr intValue] ==2 || [subStr intValue] ==3 || [subStr intValue] ==4) {
            [self callWSUploadFile];
        }
        else
        {
            [CommonHelper showAlert:NSLocalizedString(@"TXT_INVALID_FAX",nil)];
        }
    }
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}


-(void) callWSUploadFile
{
//    CGSize pageSize = CGSizeMake(1654, 2338);
//    CGRect imageBoundsRect = CGRectMake(50, 50, 1554, 2238);
//    
//    NSData *pdfData = [PDFImageConverter convertImageToPDF: self.imgBG.image
//                                            withResolution: 72 maxBoundsRect: imageBoundsRect pageSize: pageSize];
    self.subProgress.frame = self.view.frame;
    [self.view addSubview:self.subProgress];
    
    UIImage *img = [CommonHelper imageWithImage:self.imgUpload scaledToMaxWidth:1024 maxHeight:1024];
     NSData *data = UIImageJPEGRepresentation(img,0.6);
    _dataIMG = data;
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmSS"];
    dateString = [formatter stringFromDate:[NSDate date]];
    //make a file name to write the data to using the documents directory:
    _strImage =[NSString stringWithFormat:@"FN%@%d.jpg",dateString,[self getRandomNumberBetween:1 to:1000]];
//    NSString *str =[NSString stringWithFormat:@"%@.jpg",dateString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.hemakgroup.com"]];
    NSDictionary *parameter = nil;
    
    NSMutableURLRequest *afRequest = [httpClient multipartFormRequestWithMethod:@"POST" path:@"http://hemakgroup.com/new-faxupload-file.php" parameters:parameter constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:data name:@"file"
                                                                  fileName:_strImage
                                                                  mimeType:@"application/octet-stream"];
                                      }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [afRequest setTimeoutInterval:120];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *response = [operation.responseString JSONValue];
        NSLog(@"Reponse %@",operation.responseString);
        _url = operation.responseString;
        [self callWS:[self stringByTrimString:_url] andFaxNUmber:_strPhone];

//        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TXT_FAXMACHINE",nil) message:NSLocalizedString(@"TXT_DOCUMENT_SEND",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//        alert.tag = 100;
//        [alert show];
        //
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",  error);
        [CommonHelper showAlert:error.localizedDescription];
        [self.subProgress removeFromSuperview];

    }];
    [operation setUploadProgressBlock:^(NSInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
     {
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
         float percent =(float)totalBytesWritten / totalBytesExpectedToWrite;
         float value = percent*70;
         self.lblPercent.text = [NSString stringWithFormat:@"%0.f%@",value,@"%"];
         self.progress.progress = percent;
         
     }];
    [operation start];
}
-(void) callWS:(NSString *) url andFaxNUmber:(NSString *) faxnumber
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    dateString = [formatter stringFromDate:[NSDate date]];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:LINK_WS]];
    NSDictionary *parameter = @{@"faxnumber":faxnumber,@"filename":url,@"date":dateString,@"unique_id":[[CommonHelper appDelegate] GetData:IDENTIFIER]};
    NSLog(@"Param %@",parameter);
    NSURLRequest *request = [httpClient requestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/faxnew/new-fax-send.php",LINK_WS] parameters:parameter];
    AFHTTPRequestOperation *operation1 = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Success
         NSLog(@"Reponse %@",operation.responseString);
        NSString *transantion = [self stringByTrimString:operation.responseString];
        self.lblPercent.text = @"100%";

        if ([transantion isEqualToString:@"0"]) {
            [self.subProgress removeFromSuperview];
        }
        else
        {

            [CommonHelper  hideBusyView];
            [CommonHelper showAlertWithBlock:NSLocalizedString(@"TXT_DOCUMENT_SEND",nil) block:^{
                [self.subProgress removeFromSuperview];

                int number = [[[NSUserDefaults standardUserDefaults] valueForKey:NUMBER_FAX] intValue];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",number-1] forKey:NUMBER_FAX];
                [[NSUserDefaults standardUserDefaults] synchronize];
                /*
                 //NSData *data = UIImageJPEGRepresentation(self.imgUpload,1);
                 if (_dataIMG.length) {
                 [NSFileManager addFile:_dataIMG fileName:_strImage intoFolder:@""];
                 [FakDAO saveHistory:transantion andImage:_strImage];
                 }
                 */
                [CommonHelper appDelegate].isHistory = YES;
                HistoryVC *historyVC = [[HistoryVC alloc] init];
                
                [self.navigationController pushViewController:historyVC animated:YES];
            }];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [CommonHelper showAlert:error.localizedDescription];
        NSLog(@"AFHTTPRequestOperation Failure: %@", error);
        [CommonHelper hideBusyView];
        
    }];
    [operation1 start];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {
        switch (buttonIndex) {
            case 0:
            {
                [CommonHelper showBusyView];
                [self callWS:[self stringByTrimString:_url] andFaxNUmber:_strPhone];
            }
                break;
                
            default:
                break;
        }
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSString *) stringByTrimString:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSString *strPhone =[self stringByTrimString:self.txfPhone.text];
    NSRange replaceRange = [strPhone rangeOfString:@"("];
    if (replaceRange.location != NSNotFound){
        NSString* result = [strPhone stringByReplacingCharactersInRange:replaceRange withString:@""];
        self.txfPhone.text = result;
    }
    
    NSString *strPhone1 =[self stringByTrimString:self.txfPhone.text];
    NSRange replaceRange1 = [strPhone1 rangeOfString:@")"];
    if (replaceRange1.location != NSNotFound){
        NSString* result1 = [strPhone1 stringByReplacingCharactersInRange:replaceRange1 withString:@""];
        self.txfPhone.text = result1;
    }
    if (textField ==self.txfPhone) {
        textField.inputAccessoryView = [customkeyboard getToolbarWithPrevNextDone:YES :NO];
        _indexKeyboard =1;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
   
    if (string.length > 0) {
        NSString *currentTextfield= [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (currentTextfield.length>10) {
            return NO;
        }
    }
    else
    {
        return YES;
    }
    
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
   
    return YES;
}

- (void)doneClicked:(NSUInteger)selectedId
{
    [self.txfPhone resignFirstResponder];
    return;
}

- (void)cancelClicked:(NSUInteger)selectedId
{
    [self.txfPhone resignFirstResponder];
}

- (void)validateNumber{
    if (![CommonHelper connectedInternet]) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_NETWORK", nil)];
        return;
    }

    NSString *code = self.btnCountryCode.titleLabel.text;
    code = [code stringByReplacingOccurrencesOfString:@"+" withString:@""];
    if (code.length == 0) {
        [CommonHelper showAlert:NSLocalizedString(@"TXT_INVALID_FAX",nil)];
        return;
    }
    [[NetworkService createInstance]checkNumber:code number:self.txfPhone.text callback:^(BOOL isValid) {
        if (isValid) {
            _strPhone =[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,self.txfPhone.text];
            [self callWSUploadFile];
        }else{
            [CommonHelper showAlert:NSLocalizedString(@"TXT_INVALID_FAX",nil)];
        }
    }];
}

@end
