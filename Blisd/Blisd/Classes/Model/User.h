//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface User : NSObject

+ (User *) currentUser;

- (void) addToACLForObject:(id) object;

- (NSString *) email;


@end