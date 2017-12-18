//
//  HistoryObj.h
//  Faks Makinesi
//
//  Created by Milan Mendpara on 03/12/17.
//  Copyright (c) 2017 Milan Mendpara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryObj : NSObject

@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *transactionID;
@property(nonatomic,retain) NSString *image;
@property(nonatomic,retain) NSString *text1;
@property(nonatomic,retain) NSString *text2;
@property(nonatomic,retain) NSString *text3;

@property(nonatomic,assign) BOOL isDownload;
@property(nonatomic,assign) BOOL isSelect;

@property(nonatomic,retain) NSString *date;
@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSString *faxnumber;
@property(nonatomic,retain) NSString *duration;
@property(nonatomic,retain) NSString *imageUrl;

@end
