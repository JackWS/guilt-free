//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PFObject+NonNull.h"


@implementation PFObject (NonNull)

- (void) setNonNullObject:(id) object forKey:(NSString *) key {
    if (!object) {
        [self setObject:[NSNull null] forKey:key];
    } else {
        [self setObject:object forKey:key];
    }
}

- (id) nonNullObjectForKey:(NSString *) key {
    // Parse crashes if you try to retrieve data for a key that
    // hasn't been fetched yet, so make sure we have data first
    if (!self.isDataAvailable) {
        return nil;
    }
    id obj = [self objectForKey:key];
    if (obj == [NSNull null]) {
        return nil;
    } else {
        return obj;
    }
}

@end