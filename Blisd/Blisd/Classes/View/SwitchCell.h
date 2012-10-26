//
// Created by Kevin on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SwitchCell : UITableViewCell

@property (nonatomic, retain) UISwitch *aSwitch;

- (id) initWithReuseIdentifier:(NSString *) reuseIdentifier switchTarget:(id) target switchSelector:(SEL) selector;

@end