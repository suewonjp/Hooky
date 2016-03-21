//
//  ViewPingPongAnimator.h
//  Hooky
//
//  Created by Suewon Bahng on 3/13/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^AnimationStateHandler)(NSView* targetView, NSView* containingView);

@interface ViewPingPongAnimator : NSObject

@property NSTimeInterval duration;

+ (instancetype)animatorWithView:(NSView*)view
                  containingView:(NSView*)containingView
             initialStateHandler:(AnimationStateHandler)initHandler
                pingStateHandler:(AnimationStateHandler)pingHandler
                pongStateHandler:(AnimationStateHandler)pongHandler;

- (void)reset;

- (void)ping;

- (void)pong;

- (void)toggle;

@end
