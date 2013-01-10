//
// Created by Kevin on 8/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSDictionary+Helpers.h"


@implementation NSDictionary (Helpers)

- (id) nonNullObjectForKey:(id) aKey {
	id obj = [self objectForKey:aKey];
	if (obj == [NSNull null]) {
		return nil;
	}
	return obj;
}

@end