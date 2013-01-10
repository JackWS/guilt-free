//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "User.h"
#import "IntroState.h"

@interface User()

@property (nonatomic, retain) PFUser *pfUser;

@end

@implementation User

+ (User *) instance {
    static User *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (User *) currentUser {
    static User *_currentUser = nil;

    @synchronized (self) {
        if (_currentUser == nil) {
            _currentUser = [[self alloc] init];
        }
    }
    _currentUser.pfUser = [PFUser currentUser];
    return _currentUser;
}

- (void) addToACLForObject:(id) object {
    if ([object isKindOfClass:[PFObject class]]) {
        PFObject *pfObject = (PFObject *) object;
        if (![pfObject ACL]) {
            [pfObject setACL:[PFACL ACLWithUser:self.pfUser]];
        } else {
            PFACL *acl = [pfObject ACL];
            [acl setReadAccess:YES forUser:self.pfUser];
            [acl setWriteAccess:YES forUser:self.pfUser];
        }
    }
}

- (void) logOut {
    [PFUser logOut];
}

static NSString *kIntroStateKey = @"introState";

- (void) restoreState {
    NSDictionary *introStateDict = [[NSUserDefaults standardUserDefaults] objectForKey:kIntroStateKey];
    self.introState = [IntroState fromDictionary:introStateDict];
}

- (void) saveState {
    if (self.introState) {
        [[NSUserDefaults standardUserDefaults] setObject:[self.introState toDictionary]
                                                  forKey:kIntroStateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (NSString *) email {
    return self.pfUser.email;
}

- (NSString *) userId {
    return self.pfUser.objectId;
}

- (BOOL) loggedIn {
    return self.pfUser.isAuthenticated;
}


- (UserType) userType {
    if ([PFFacebookUtils isLinkedWithUser:self.pfUser]) {
        return UserTypeFacebook;
    } else if ([PFTwitterUtils isLinkedWithUser:self.pfUser]) {
        return UserTypeTwitter;
    } else {
        return UserTypePassword;
    }
}

@end