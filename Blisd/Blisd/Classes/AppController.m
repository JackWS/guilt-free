//
//  AppController.m
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <Parse/Parse.h>
#import "AppController.h"
#import "ScanViewController.h"
#import "BlissViewController.h"
#import "LogInViewController.h"
#import "SignUpViewController.h"
#import "User.h"
#import "DealsViewController.h"
#import "SettingsViewController.h"
#import "InfoViewController.h"
#import "UncaughtExceptionHandler.h"
#import "Location.h"
#import "LocationManager.h"
#import "Facebook.h"

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
    [[FBSession activeSession] handleDidBecomeActive];
    [[LocationManager instance] findLocation];
}

- (void) applicationDidEnterBackground:(UIApplication *) application {
    [[LocationManager instance] stopFindingLocation];
}


- (void) application:(UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    [self handlePushRegistrationWithToken:deviceToken];
}

- (void) application:(UIApplication *) application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"Error registering for remote notifications: %@", [error localizedDescription]);
}

- (void) application:(UIApplication *) application didReceiveRemoteNotification:(NSDictionary *) userInfo {
    [PFPush handlePush:userInfo];
}

- (void) applicationWillTerminate:(UIApplication *) application {
    [[User currentUser] saveState];
}


#pragma mark Initialization

- (void) initialize {
    InstallUncaughtExceptionHandler();

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
            UIRemoteNotificationTypeBadge |
            UIRemoteNotificationTypeAlert |
            UIRemoteNotificationTypeSound];

    [self initializeParse];
    [self initializeState];
    [self initializeUI];
}

- (void) initializeParse {
    [Parse setApplicationId:@"HjWLIOOPAcDdAGLosSh8nDY3OhB5Onh5LCdmW0en"
                  clientKey:@"Ua9MSXaabmMYAl0ZaLJirzdtuF4Cdb3ZlXRzm09F"];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"CGsQrEsgk8Z0EUHPc0BQ"
                               consumerSecret:@"91ZWdE68oPCmrOlxWdqkpUQakGECrwpWnUQbkgdBvwk"];
}

- (void) initializeState {
    [[User currentUser] restoreState];
}

- (void) initializeUI {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *scanController = [[ScanViewController alloc] initWithNibName:@"ScanViewController_iPhone" bundle:nil];
    UIViewController *blissController = [[BlissViewController alloc] initWithNibName:@"BlissViewController_iPhone" bundle:nil];
    UIViewController *dealsController = [[DealsViewController alloc] initWithNibName:@"DealsView" bundle:nil];
    UIViewController *settingsController = [[SettingsViewController alloc] init];
    UIViewController *infoController = [[InfoViewController alloc] init];
    self.tabBarController = [[UITabBarController alloc] init];

    UINavigationController *scanNavController = [[UINavigationController alloc] initWithRootViewController:scanController];
    [scanNavController setNavigationBarHidden:YES animated:NO];

    UINavigationController *blissNavController = [[UINavigationController alloc] initWithRootViewController:blissController];
    [blissNavController setNavigationBarHidden:YES animated:NO];

    UINavigationController *dealsNavController = [[UINavigationController alloc] initWithRootViewController:dealsController];
    [dealsNavController setNavigationBarHidden:YES animated:NO];

    self.tabBarController.viewControllers = @[scanNavController, blissNavController, dealsNavController, settingsController, infoController];
    self.tabBarController.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bar_bg.png"];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    if (![User currentUser].loggedIn) {
        [self displayLogInAnimated:NO];
    }
}

- (void) handlePushRegistrationWithToken:(NSData *) deviceToken {
    NSLog(@"Received device token: %@", [deviceToken description]);
    [PFPush storeDeviceToken:deviceToken]; // Send parse the device token
    // Subscribe this user to the broadcast channel, ""
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the broadcast channel.");
        } else {
            NSLog(@"Failed to subscribe to the broadcast channel.");
        }
    }];
}

#pragma mark Helpers

- (void) logOut {
    [[User currentUser] logOut];
    [self displayLogInAnimated:YES];

    [NSTimer scheduledTimerWithTimeInterval:1
                                      block:^(NSTimeInterval time) {
                                          [self.tabBarController setSelectedIndex:0];
                                      } repeats:NO];
}

- (void) displayLogInAnimated:(BOOL) animated {
    LogInViewController *logInViewController = [[LogInViewController alloc] init];
    logInViewController.delegate = self;
    logInViewController.signUpController = [[SignUpViewController alloc] init];
    logInViewController.signUpController.delegate = self;
    [self.tabBarController presentModalViewController:logInViewController animated:animated];
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
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }

    if (FBSession.activeSession.isOpen) {
        // Initiate a Facebook instance and properties
        if (nil == self.facebook) {
            self.facebook = [[Facebook alloc]
                    initWithAppId:FBSession.activeSession.appID
                      andDelegate:nil];

            // Store the Facebook session information
            self.facebook.accessToken = FBSession.activeSession.accessToken;
            self.facebook.expirationDate = FBSession.activeSession.expirationDate;
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
    return [FBSession openActiveSessionWithReadPermissions:nil
                                          allowLoginUI:YES
                                     completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                         [self sessionStateChanged:session
                                                             state:status
                                                             error:error];
                                     }];
}


@end
