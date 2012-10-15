//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "ScanLog.h"
#import "PFObject+NonNull.h"


@implementation ScanLog {

}

static NSString *const kClassName = @"ULog";

static NSString *const kUserKey = @"User";
static NSString *const kCampaignNumberKey = @"campaignNumber";

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }
    [obj setNonNullObject:self.user forKey:kUserKey];
    [obj setNonNullObject:self.campaignNumber forKey:kCampaignNumberKey];

    return obj;
}


@end