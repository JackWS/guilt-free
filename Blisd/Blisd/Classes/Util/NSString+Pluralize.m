//
// Created by Kevin on 10/15/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSString+Pluralize.h"


@implementation NSString (Pluralize)

- (NSString *) pluralize:(NSInteger) count {
    if (count == 1) {
        return $str(@"%d %@", count, self);
    } else {
        return $str(@"%d %@s", count, self);
    }
}

@end