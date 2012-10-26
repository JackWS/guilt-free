//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InfoViewController.h"

@interface InfoViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation InfoViewController {


}

- (id) init {
    self = [super init];
    if (self) {
        [self initialize];
    }

    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];;
    }
    return self;
}

- (void) initialize {
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttoninfopressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttoninfo.png"]];
}


- (void) loadView {

    UIWebView *webView = [[UIWebView alloc] init];

    self.webView = webView;
    self.view = webView;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    // Thank god StackOverflow could provide this magical incantation
    // http://stackoverflow.com/a/8436281/1123420
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html" inDirectory:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


@end