//
// Created by Kevin on 11/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CheckInScanLog.h"
#import "PFObject+NonNull.h"
#import "CheckInBalance.h"


@implementation CheckInScanLog {

}

static NSString *const kClassName = @"CLog";

static NSString *const kBalanceKey = @"cbal_Pointer";
static NSString *const kUserKey = @"user_Pointer";

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }
    [obj setNonNullObject:[self.balance toPFObject] forKey:kBalanceKey];
    [obj setNonNullObject:[PFUser currentUser] forKey:kUserKey];

    return obj;
}

@end