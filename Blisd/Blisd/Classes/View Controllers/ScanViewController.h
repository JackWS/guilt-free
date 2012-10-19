//
//  ScanViewController.h
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderView.h"
#import "BlisdModel.h"

@interface ScanViewController : UIViewController<ZBarReaderViewDelegate>

@property(nonatomic, retain) IBOutlet ZBarReaderView *readerView;

@end
