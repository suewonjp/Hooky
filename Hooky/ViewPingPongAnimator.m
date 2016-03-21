//
//  ViewPingPongAnimator.m
//  Hooky
//
//  Created by Suewon Bahng on 3/13/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "ViewPingPongAnimator.h"
#import "Utils.h"

typedef NS_OPTIONS(unsigned int, AnimationState) {
    AnimationStateInitial,
    AnimationStatePing,
    AnimationStatePong,
};

@interface ViewPingPongAnimator () {
    __weak NSView*          view;
    __weak NSView*          containingView;
    AnimationStateHandler   initHandler;
    AnimationStateHandler   pingHandler;
    AnimationStateHandler   pongHandler;
    AnimationState          curState;
}

@end

@implementation ViewPingPongAnimator

+ (instancetype)animatorWithView:(NSView*)view
                  containingView:(NSView*)containingView
             initialStateHandler:(AnimationStateHandler)initHandler
                pingStateHandler:(AnimationStateHandler)pingHandler
                pongStateHandler:(AnimationStateHandler)pongHandler {
    RT_ASSERT(view && initHandler && pingHandler && pongHandler);
    ViewPingPongAnimator* output = [[ViewPingPongAnimator alloc] init];
    output.duration = 1.0f;
    output->curState = AnimationStateInitial;
    output->view = view;
    output->containingView = containingView ? containingView : [view superview];
    output->initHandler = initHandler;
    output->pingHandler = pingHandler;
    output->pongHandler = pongHandler;
    return output;
}

- (void)reset {
    self->initHandler(self->view, self->containingView);
    self->curState = AnimationStateInitial;
}

- (void)ping {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:self.duration];
    self->pingHandler(self->view, self->containingView);
    [NSAnimationContext endGrouping];
    
    self->curState = AnimationStatePing;
}

- (void)pong {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:self.duration];
    self->pongHandler(self->view, self->containingView);
    [NSAnimationContext endGrouping];
    
    self->curState = AnimationStatePong;
}

- (void)toggle {
    if (self->curState == AnimationStatePing) {
        [self pong];
    }
    else {
        [self ping];
    }
}

@end
