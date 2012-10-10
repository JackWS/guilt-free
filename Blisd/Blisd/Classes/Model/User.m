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

+ (User *) userFromPFUser:(PFUser *) pfUser {
    User *user = [[User alloc] init];
    user.pfUser = pfUser;

    return user;
}

@end