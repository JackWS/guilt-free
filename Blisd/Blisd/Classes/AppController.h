//
//  AppController.h
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppController : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
