//
//  AppController.h
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class Facebook;

extern NSString *const kAppControllerDidChangeFacebookStatusNotification;

@interface AppController : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, strong) Facebook *facebook;

+ (AppController *) instance;

- (void) logOut;


- (BOOL) openSessionWithAllowLoginUI:(BOOL) allowLoginUI;

@end
