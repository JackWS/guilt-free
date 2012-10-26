//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
    UserTypePassword,
    UserTypeFacebook,
    UserTypeTwitter
} UserType;

@interface User : NSObject

@property (readonly) NSString *userId;
@property (readonly) UserType userType;
@property (readonly) NSString *email;

+ (User *) currentUser;

- (void) addToACLForObject:(id) object;
- (void) logOut;

@end