//
// Created by Kevin on 10/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PFImageView;

@interface BlissTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet PFImageView *logoImageView;
@property (nonatomic, strong) IBOutlet UILabel *businessLabel;
@property (nonatomic, strong) IBOutlet UILabel *rewardLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

@end