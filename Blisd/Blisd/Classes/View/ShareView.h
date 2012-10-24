//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ShareHelper.h"


@interface ShareView : UIView <PF_FBDialogDelegate, PF_FBSessionDelegate>

@property (nonatomic, retain) ShareHelper *shareHelper;

@property (nonatomic, assign) NSInteger progress;

@property (nonatomic, assign) IBOutlet UIViewController *ownerViewController;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (IBAction) shareFacebook:(id) sender;

- (IBAction) shareTwitter:(id) sender;

- (IBAction) shareEmail:(id) sender;

@end