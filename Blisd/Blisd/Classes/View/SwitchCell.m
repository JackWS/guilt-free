//
// Created by Kevin on 9/17/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SwitchCell.h"


@implementation SwitchCell

- (id) initWithReuseIdentifier:(NSString *) reuseIdentifier switchTarget:(id) target switchSelector:(SEL) selector {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.numberOfLines = 0;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.aSwitch = [[UISwitch alloc] init];
                    [self.aSwitch addTarget:target
                                action:selector
                      forControlEvents:UIControlEventValueChanged];

    }

    return self;
}

#pragma mark UIView over-rides

- (void) layoutSubviews {
    [super layoutSubviews];

    if (!self.aSwitch.superview) {
        [self.contentView addSubview:self.aSwitch];
    }

    CGFloat height = self.contentView.frame.size.height;
    self.aSwitch.frame = CGRectMake(self.contentView.frame.size.width - self.aSwitch.frame.size.width - 10,
            (height - self.aSwitch.frame.size.height)/2,
            self.aSwitch.frame.size.width, self.aSwitch.frame.size.height);

    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x,
            self.textLabel.frame.origin.y,
            self.textLabel.frame.size.width - self.aSwitch.frame.size.width - 10,
            self.textLabel.frame.size.height);

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end