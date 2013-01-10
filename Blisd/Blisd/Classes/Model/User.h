//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class IntroState;

typedef enum {
    UserTypePassword,
    UserTypeFacebook,
    UserTypeTwitter
} UserType;

@interface User : NSObject

@property (readonly) NSString *userId;
@property (readonly) UserType userType;
@property (readonly) NSString *email;
@property (readonly) BOOL loggedIn;

@property (nonatomic, strong) IntroState *introState;

+ (User *) instance;

+ (User *) currentUser;

- (void) addToACLForObject:(id) object;
- (void) logOut;

- (void) restoreState;
- (void) saveState;

@end