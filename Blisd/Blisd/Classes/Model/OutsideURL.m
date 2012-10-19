//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "OutsideURL.h"
#import "PFObject+NonNull.h"


@implementation OutsideURL {

}

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:@"LogOutsideUrls"];
    }
    [obj setNonNullObject:self.url forKey:@"URL"];
    [obj setNonNullObject:self.user forKey:@"User"];

    return obj;
}


@end