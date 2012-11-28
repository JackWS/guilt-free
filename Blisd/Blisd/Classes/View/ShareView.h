//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ShareHelper.h"

@class CheckInBalance;


@interface ShareView : UIView

@property (nonatomic, retain) ShareHelper *shareHelper;

@property (nonatomic, retain) CheckInBalance *balance;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (IBAction) shareFacebook:(id) sender;

- (IBAction) shareTwitter:(id) sender;

- (IBAction) shareEmail:(id) sender;

@end