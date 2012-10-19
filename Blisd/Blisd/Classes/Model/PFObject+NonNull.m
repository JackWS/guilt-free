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
    id obj = [self objectForKey:key];
    if (obj == [NSNull null]) {
        return nil;
    } else {
        return obj;
    }
}

@end