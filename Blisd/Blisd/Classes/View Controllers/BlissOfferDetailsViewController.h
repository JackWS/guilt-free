//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Balance;
@class ShareView;


@interface BlissOfferDetailsViewController : UIViewController

@property (nonatomic, strong) Balance *balance;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UIView *detailsView;

@property (nonatomic, strong) IBOutlet UIImageView *businessImageView;
@property (nonatomic, strong) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *businessTagLineLabel;
@property (nonatomic, strong) IBOutlet UILabel *businessTypeLabel;

@property (nonatomic, strong) IBOutlet UILabel *countRemainingLabel;
@property (nonatomic, strong) IBOutlet UILabel *buyXLabel;
@property (nonatomic, strong) IBOutlet UILabel *getXLabel;

@property (nonatomic, retain) IBOutlet UIView *shareViewContainer;
@property (nonatomic, retain) IBOutlet ShareView *shareView;

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *websiteLabel;

- (IBAction) back:(id) sender;

- (IBAction) openWebsite:(id) sender;

@end