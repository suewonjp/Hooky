//
//  EventMonitor.h
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/2/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "EventHookStore.h"
#import <Cocoa/Cocoa.h>

typedef void (^EventHookHandler)(NSEvent*);

@interface EventHookManager : NSObject

@property (nonatomic, readonly) EventHookStore* hookStore;

+ (EventHookManager*)eventHookWithDefaultHandler:(EventHookHandler)handler;

- (void)start;

- (void)stop;

- (void)activate:(BOOL)yes;

- (BOOL)active;

@end

//
// NSValue + EventHookItem
//
@interface NSValue (EventHookItem)
+ (instancetype)valueWithEventHookItem:(const EventHookItem*)rawData;
@property (readonly) EventHookItem eventHookItem;
@end
