//
//  Created by Kevin on 4/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@class MBProgressHUD;


@interface HUDHelper : NSObject <MBProgressHUDDelegate>

@property (nonatomic, retain) UIView *view;

@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, assign) id <MBProgressHUDDelegate> delegate;

- (id) initWithView:(UIView *) view;

- (id) initWithView:(UIView *) view delegate:(id<MBProgressHUDDelegate>) delegate;

- (void) showWithText:(NSString *) text;

- (void) hide;

- (void) hideWithCheckmarkAndText:(NSString *) text;

- (void) hideAnimated:(BOOL) animated;


@end