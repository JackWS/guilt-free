//
//  AppController.m
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import "AppController.h"

#import "ScanViewController.h"

#import "BlissViewController.h"
#import "LogInViewController.h"
#import "SignUpViewController.h"
#import "User.h"

NSString *const kAppControllerDidChangeFacebookStatusNotification = @"AppControllerDidChangeFacebookStatusNotification";

@interface AppController ()

@end

@implementation AppController

+ (AppController *) instance {
    return (AppController *) [UIApplication sharedApplication].delegate;
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initialize];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void) applicationDidBecomeActive:(UIApplication *) application {
    [[PF_FBSession activeSession] handleDidBecomeActive];
}


#pragma mark Initialization

- (void) initialize {
    [self initializeParse];
    [self initializeUI];
}

- (void) initializeParse {
    [Parse setApplicationId:@"HjWLIOOPAcDdAGLosSh8nDY3OhB5Onh5LCdmW0en"
                  clientKey:@"Ua9MSXaabmMYAl0ZaLJirzdtuF4Cdb3ZlXRzm09F"];
    [PFFacebookUtils initializeWithApplicationId:@"132484773511826"];
    [PFTwitterUtils initializeWithConsumerKey:@"CGsQrEsgk8Z0EUHPc0BQ"
                               consumerSecret:@"91ZWdE68oPCmrOlxWdqkpUQakGECrwpWnUQbkgdBvwk"];
}

- (void) initializeUI {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController1 = [[ScanViewController alloc] initWithNibName:@"ScanViewController_iPhone" bundle:nil];
        viewController2 = [[BlissViewController alloc] initWithNibName:@"BlissViewController_iPhone" bundle:nil];
    } else {
        viewController1 = [[ScanViewController alloc] initWithNibName:@"ScanViewController_iPad" bundle:nil];
        viewController2 = [[BlissViewController alloc] initWithNibName:@"BlissViewController_iPad" bundle:nil];
    }
    self.tabBarController = [[UITabBarController alloc] init];

    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    [navController1 setNavigationBarHidden:YES animated:NO];

    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    [navController2 setNavigationBarHidden:YES animated:NO];
    self.tabBarController.viewControllers = @[navController1, navController2];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    if (![User currentUser]) {
        LogInViewController *logInViewController = [[LogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.signUpController = [[SignUpViewController alloc] init];
        logInViewController.signUpController.delegate = self;
        [self.tabBarController presentModalViewController:logInViewController animated:NO];
    }
}

#pragma mark PFLogInViewControllerDelegate

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {

}

#pragma mark PFSignUpViewControllerDelegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    user.email = user.username;
    NSError *error = nil;
    BOOL success = [user save:&error];
    if (!success) {
        NSString *errorMessage;
        if ([error code] == 125) {
            errorMessage = $str(@"The email address \"%@\" is invalid.", user.username);
        } else {
            errorMessage = [[error userInfo] objectForKey:@"error"];
        }
        [user deleteEventually];
        NSLog(@"error: %@", [error description]);
        [[[UIAlertView alloc] initWithTitle:@"Account Error"
                                    message:errorMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }

    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {

}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    NSLog(@"signup info: %@", [info description]);

    return YES;
}

#pragma mark Facebook

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(PF_FBSession *)session
                      state:(PF_FBSessionState) state
                      error:(NSError *)error {
    switch (state) {
        case PF_FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case PF_FBSessionStateClosed:
        case PF_FBSessionStateClosedLoginFailed:
            [PF_FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }

    if (PF_FBSession.activeSession.isOpen) {
        // Initiate a Facebook instance and properties
        if (nil == self.facebook) {
            self.facebook = [[PF_Facebook alloc]
                    initWithAppId:PF_FBSession.activeSession.appID
                      andDelegate:nil];

            // Store the Facebook session information
            self.facebook.accessToken = PF_FBSession.activeSession.accessToken;
            self.facebook.expirationDate = PF_FBSession.activeSession.expirationDate;
        }
    } else {
        // Clear out the Facebook instance
        self.facebook = nil;
    }

    [[NSNotificationCenter defaultCenter]
            postNotificationName:kAppControllerDidChangeFacebookStatusNotification
                          object:session];



    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:@"Error"
                      message:error.localizedDescription
                     delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [PF_FBSession openActiveSessionWithReadPermissions:nil
                                          allowLoginUI:YES
                                     completionHandler:^(PF_FBSession *session, PF_FBSessionState status, NSError *error) {
                                         [self sessionStateChanged:session
                                                             state:status
                                                             error:error];
                                     }];
}


@end
