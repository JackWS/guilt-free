//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PFObject (NonNull)

- (void) setNonNullObject:(id) object forKey:(NSString *) key;

- (id) nonNullObjectForKey:(NSString *) key;

@end