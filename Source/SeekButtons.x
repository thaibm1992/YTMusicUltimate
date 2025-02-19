#import "SeekButtons.h"

static NSInteger currentSeekTime() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"seekTime"];
}

%group gSeekButtons
@implementation UIView (NearestViewController)
- (UIViewController *)nearestViewController {
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        } responder = responder.nextResponder;
    } return nil;
}
@end

%hook YTMPlayerControlsView
- (void)layoutSubviews {
    %orig;

    UIButton *prevButton = [self prevButton];
    UIButton *nextButton = [self nextButton];

    NSSet *prevTargets = [prevButton allTargets];
    for (id prevTarget in prevTargets) {
        NSArray *actions = [prevButton actionsForTarget:prevTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapPrevButton"]) {
                [prevButton removeTarget:prevTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [prevButton addTarget:prevTarget action:@selector(didTapSeekBackwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    NSSet *nextTargets = [nextButton allTargets];
    for (id nextTarget in nextTargets) {
        NSArray *actions = [nextButton actionsForTarget:nextTarget forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            if ([action isEqualToString:@"didTapNextButton"]) {
                [nextButton removeTarget:nextTarget action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                [nextButton addTarget:nextTarget action:@selector(didTapSeekForwardButton) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }

    UILongPressGestureRecognizer *longPressPrev = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPrev:)];
    [longPressPrev setMinimumPressDuration:0.5];
    [prevButton addGestureRecognizer:longPressPrev];

    UILongPressGestureRecognizer *longPressNext = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressNext:)];
    [longPressNext setMinimumPressDuration:0.5];
    [nextButton addGestureRecognizer:longPressNext];


    NSString *backValue = @"10";
    NSString *forwardValue = @"30";

    if (currentSeekTime() != 0) {
        NSArray *values = @[@"10", @"20", @"30", @"60"];
        NSInteger seekTime = currentSeekTime() - 1;
        backValue = values[seekTime];
        forwardValue = values[seekTime];
    }

    NSString *appBundle = [[NSBundle mainBundle] bundlePath];
    UIImage *backImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_seek_back_%@_40", backValue] inBundle:[NSBundle bundleWithPath:appBundle] compatibleWithTraitCollection:nil];
    UIImage *forwardImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_seek_forward_%@_40", forwardValue] inBundle:[NSBundle bundleWithPath:appBundle] compatibleWithTraitCollection:nil];

    [prevButton setImage:backImage forState:UIControlStateNormal];
    [prevButton setImage:backImage forState:UIControlStateSelected];
    [nextButton setImage:forwardImage forState:UIControlStateNormal];
    [nextButton setImage:forwardImage forState:UIControlStateSelected];
}

- (void)didTapSeekBackwardButton {
    [self didTapSeekBackwardButton];
}

- (void)didTapSeekForwardButton {
    [self didTapSeekForwardButton];
}

%new - (void)longPressPrev:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        YTMNowPlayingViewController *parentVC = (YTMNowPlayingViewController *)[self nearestViewController];
        if (parentVC) [parentVC didTapPrevButton];
    }
}

%new - (void)longPressNext:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        YTMNowPlayingViewController *parentVC = (YTMNowPlayingViewController *)[self nearestViewController];
        if (parentVC) [parentVC didTapNextButton];
    }
}

%end

%hook YTColdConfig
- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekForwardTime {
    NSArray *values = @[@"%orig", @10, @20, @30, @60];
    NSInteger seekTime = currentSeekTime();

    return (seekTime == 0) ? [values[0] integerValue] : [values[seekTime] integerValue];
}

- (NSInteger)iosPlayerClientSharedConfigTransportControlsSeekBackwardTime {
    NSArray *values = @[@"%orig", @10, @20, @30, @60];
    NSInteger seekTime = currentSeekTime();

    return (seekTime == 0) ? [values[0] integerValue] : [values[seekTime] integerValue];
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL seekButtons = [[NSUserDefaults standardUserDefaults] boolForKey:@"seekButtons_enabled"];

    if (isEnabled && seekButtons){
        %init(gSeekButtons);
    }
}
