//
// Created by Kevin on 10/15/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Balance.h"

@interface PostScanViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *flareImageView;
@property (nonatomic, strong) IBOutlet UIButton *redeemButton;
@property (nonatomic, strong) IBOutlet UIView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *buyXLabel;
@property (nonatomic, strong) IBOutlet UILabel *earnLabel;
@property (nonatomic, strong) IBOutlet UILabel *getXLabel;

@property (nonatomic, strong) IBOutlet UIView *shareView;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (id) initWithBalance:(Balance *) balance;

- (IBAction) back:(id) sender;

- (IBAction) redeem:(id) sender;

- (IBAction) shareFacebook:(id) sender;

- (IBAction) shareTwitter:(id) sender;

- (IBAction) shareEmail:(id) sender;


@end