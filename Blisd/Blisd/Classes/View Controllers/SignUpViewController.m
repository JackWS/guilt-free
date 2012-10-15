//
//  SignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "SignUpViewController.h"
#import "NIBLoader.h"
#import "LoginHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation SignUpViewController

@synthesize fieldsBackground;

- (id)init {
    self = [super init];
    if (self) {
        self.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton;
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    LoginHeaderView *headerView = [NIBLoader loadFirstObjectFromNibNamed:@"LoginHeaderView"];
    headerView.headerLabel.text = NSLocalizedString(@"SIGNUP_PROMPT", @"");
    self.signUpView.logo = headerView;

    self.signUpView.backgroundColor = [UIColor blackColor];

    self.signUpView.usernameField.backgroundColor = [UIColor whiteColor];
    self.signUpView.usernameField.borderStyle = UITextBorderStyleBezel;
    self.signUpView.usernameField.placeholder = NSLocalizedString(@"SIGN_UP_EMAIL_PLACEHOLDER", @"");
    self.signUpView.usernameField.textColor = [UIColor blackColor];
    self.signUpView.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.signUpView.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    self.signUpView.passwordField.backgroundColor = [UIColor whiteColor];
    self.signUpView.passwordField.borderStyle = UITextBorderStyleBezel;
    self.signUpView.passwordField.placeholder = NSLocalizedString(@"SIGN_UP_PASSWORD_PLACEHOLDER", @"");
    self.signUpView.passwordField.textColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
