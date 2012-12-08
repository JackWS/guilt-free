//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "BlissScanLog.h"
#import "PFObject+NonNull.h"
#import "BlissBalance.h"

@implementation BlissScanLog {

}

static NSString *const kClassName = @"ULog";

static NSString *const kUserKey = @"user_Pointer";
static NSString *const kBalanceKey = @"bal_Pointer";

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }
    [obj setNonNullObject:[PFUser currentUser] forKey:kUserKey];
    [obj setNonNullObject:[self.balance toPFObject] forKey:kBalanceKey];

    return obj;
}


@end