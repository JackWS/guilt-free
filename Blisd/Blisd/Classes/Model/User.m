//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "User.h"

@interface User()

@property (nonatomic, retain) PFUser *pfUser;

@end

@implementation User

+ (User *) currentUser {
    return [User userFromPFUser:[PFUser currentUser]];
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


- (NSString *) email {
    return self.pfUser.email;
}

+ (User *) userFromPFUser:(PFUser *) pfUser {
    if (!pfUser) {
        return nil;
    }

    User *user = [[User alloc] init];
    user.pfUser = pfUser;

    return user;
}

@end