//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class ShareHelper;

typedef enum {
    ShareServiceFacebook,
    ShareServiceTwitter
} ShareService;

@protocol ShareHelperDelegate<NSObject>

- (UIViewController *) viewControllerForShareHelper:(ShareHelper *) shareHelper;
- (void) shareHelper:(ShareHelper *) shareHelper didStartShareWithService:(ShareService) shareService;
- (void) shareHelper:(ShareHelper *) shareHelper didCancelShareWithService:(ShareService) shareService;
- (void) shareHelper:(ShareHelper *) shareHelper
     didReceiveError:(NSError *) error
 forShareWithService:(ShareService) shareService;

- (NSString *) shareHelper:(ShareHelper *) shareHelper textForShareWithService:(ShareService) shareService;
- (NSString *) shareHelper:(ShareHelper *) shareHelper nameForShareWithService:(ShareService) shareService;
- (NSString *) shareHelper:(ShareHelper *) shareHelper captionForShareWithService:(ShareService) shareService;
- (NSString *) shareHelper:(ShareHelper *) shareHelper descriptionForShareWithService:(ShareService) shareService;

- (NSURL *) shareHelper:(ShareHelper *) shareHelper URLForShareWithService:(ShareService) shareService;
- (UIImage *) shareHelper:(ShareHelper *) shareHelper imageForShareWithService:(ShareService) shareService;
- (NSURL *) shareHelper:(ShareHelper *) shareHelper imageURLForShareWithService:(ShareService) shareService;

@end

@interface ShareHelper : NSObject <PF_FBDialogDelegate>

@property (nonatomic, assign) id <ShareHelperDelegate> delegate;

- (IBAction) shareFacebook:(id) sender;

- (IBAction) shareTwitter:(id) sender;


@end