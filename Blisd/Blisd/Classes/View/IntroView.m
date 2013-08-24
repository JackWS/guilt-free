//
// Created by Kevin on 1/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "IntroView.h"

@interface IntroView ()

@property (nonatomic, retain) UIImageView *imageView;

@end

@implementation IntroView {

}

- (id) initWithImage:(UIImage *) image {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.imageView];
        __block IntroView *introView = self;
        [self addEventHandler:^(id sender) {
            [UIView animateWithDuration:0.5
                             animations:^{
                                 introView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 [introView removeFromSuperview];
                                 if (introView.doneBlock) {
                                     introView.doneBlock();
                                 }
                             }];
        } forControlEvents:UIControlEventTouchUpInside];

        self.alpha = 0.9f;
        self.imageView.alpha = 0.9f;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = self.bounds;
}


@end