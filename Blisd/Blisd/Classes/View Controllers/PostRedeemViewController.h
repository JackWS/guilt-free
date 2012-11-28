//
// Created by Kevin on 11/26/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ShareHelper.h"

@class ShareView;
@class BlissBalance;


@interface PostRedeemViewController : UIViewController <ShareHelperDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *flareImageView;
@property (nonatomic, strong) IBOutlet UIView *progressView;

@property (nonatomic, retain) IBOutlet UIView *shareViewContainer;
@property (nonatomic, strong) ShareView *shareView;

@property (nonatomic, strong) BlissBalance *balance;

- (IBAction) back:(id) sender;


@end