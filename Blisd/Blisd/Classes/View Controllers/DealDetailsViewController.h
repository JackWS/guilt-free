//
// Created by Kevin on 11/29/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ShareHelper.h"

@class Deal;
@class ShareView;


@interface DealDetailsViewController : UIViewController <ShareHelperDelegate>

@property (nonatomic, strong) Deal *deal;

@property (nonatomic, strong) IBOutlet UIView *detailsView;
@property (nonatomic, strong) IBOutlet UIView *shareViewContainer;
@property (nonatomic, strong) ShareView *shareView;

@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *businessTagLineLabel;
@property (nonatomic, strong) IBOutlet UILabel *businessTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *websiteLabel;

- (IBAction) back:(id) sender;

- (IBAction) openLink:(id) sender;


@end