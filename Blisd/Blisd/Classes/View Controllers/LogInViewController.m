//
//  LogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "LogInViewController.h"
#import "SignUpViewController.h"
#import "LoginHeaderView.h"
#import "NIBLoader.h"

@interface LogInViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation LogInViewController

@synthesize fieldsBackground;

- (id)init {
    self = [super init];
    if (self) {
        self.fields = PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten |
                PFLogInFieldsSignUpButton | PFLogInFieldsTwitter | PFLogInFieldsUsernameAndPassword;
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    LoginHeaderView *headerView = [NIBLoader loadFirstObjectFromNibNamed:@"LoginHeaderView"];
    headerView.headerLabel.text = NSLocalizedString(@"LOGIN_PROMPT", @"");
    self.logInView.logo = headerView;

    self.logInView.backgroundColor = [UIColor blackColor];

    self.logInView.usernameField.backgroundColor = [UIColor whiteColor];
    self.logInView.usernameField.borderStyle = UITextBorderStyleBezel;
    self.logInView.usernameField.placeholder = NSLocalizedString(@"LOG_IN_EMAIL_PLACEHOLDER", @"");
    self.logInView.usernameField.textColor = [UIColor blackColor];
    self.logInView.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.logInView.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    self.logInView.passwordField.backgroundColor = [UIColor whiteColor];
    self.logInView.passwordField.borderStyle = UITextBorderStyleBezel;
    self.logInView.passwordField.placeholder = NSLocalizedString(@"LOG_IN_PASSWORD_PLACEHOLDER", @"");
    self.logInView.passwordField.textColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
