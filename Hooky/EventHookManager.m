//
//  EventMonitor.m
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/2/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "EventHookManager.h"
#import "Utils.h"
#import <Carbon/Carbon.h>

//<##>
typedef struct ProxyEventProgress {
    NSTimeInterval      timestamp;
    NSTimeInterval      timestampAtTargetJobRun;
    uint32_t            modifierFlags;
    uint16_t            modifierKeyCode;
    uint8_t             mkmCount;
} ProxyEventProgress;

static void resetProxyEventProgress(ProxyEventProgress* prxEvtPrg) {
    memset(prxEvtPrg, 0, sizeof(*prxEvtPrg));
}

@implementation NSValue (EventHookItem)
+ (instancetype)valueWithEventHookItem:(const EventHookItem*)rawData {
    CT_ASSERT(sizeof(unsigned long long) == sizeof(ProxyEvent));
    // NOTE: Seems like the current compiler (Xcode 7.2.1) can't interpret @encode(ProxyEvent) ( so @encode(EventHookItem) too ) correclty.
    // So we use hard coding.
    return [self valueWithBytes:rawData objCType:"[2^Q]"];
}

- (EventHookItem) eventHookItem {
    EventHookItem rawData;
    [self getValue:&rawData];
    return rawData;
}
@end

static void postShortcutEvent(const CGKeyCode plainKey, const CGEventFlags flags) {
//    const CGEventTapLocation tap = kCGHIDEventTap;
    const CGEventTapLocation tap = kCGSessionEventTap;
    
    // Modifier keys down
    if (flags & kCGEventFlagMaskCommand) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Command, true);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskAlternate) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Option, true);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskControl) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Control, true);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskShift) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Shift, true);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    
    // Plain key down
    CGEventRef plainKeyEvent = CGEventCreateKeyboardEvent(NULL, plainKey, true);
    CGEventSetFlags(plainKeyEvent, flags);
    CGEventPost(tap, plainKeyEvent);
    CFRelease(plainKeyEvent);
    
    // Plain key up
    plainKeyEvent = CGEventCreateKeyboardEvent(NULL, plainKey, false);
    CGEventSetFlags(plainKeyEvent, flags);
    CGEventPost(tap, plainKeyEvent);
    CFRelease(plainKeyEvent);
    
    // Modifier keys up
    if (flags & kCGEventFlagMaskCommand) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Command, false);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskAlternate) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Option, false);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskControl) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Control, false);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
    if (flags & kCGEventFlagMaskShift) {
        CGEventRef evt = CGEventCreateKeyboardEvent(NULL, kVK_Shift, false);
        CGEventPost(tap, evt);
        CFRelease(evt);
    }
}



@interface EventHookManager () {
    ProxyEventProgress  onGoingProxyEvent;
    NSTimer*            timer;
    id                  monitor;
    EventHookHandler    handler;
    BOOL                active;
}

@end

@implementation EventHookManager

+ (EventHookManager*)eventHookWithDefaultHandler:(EventHookHandler)defaultHandler {
    EventHookManager* output = [[EventHookManager alloc] init];
    resetProxyEventProgress(&output->onGoingProxyEvent);
    output->timer = nil;
    output->monitor = nil;
    output->active = YES;
    
    output->_hookStore = [[EventHookStore alloc] init];
    
    EventHookManager* __weak _output = output;
    output->handler = ^(NSEvent* event) {
        if ([_output handleHooks:event] == NO) {
            if (defaultHandler)
                defaultHandler(event);
        }
    };
    
    return output;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    self->monitor = [NSEvent addGlobalMonitorForEventsMatchingMask:
                     NSLeftMouseUpMask | NSRightMouseUpMask | NSOtherMouseUpMask | NSFlagsChangedMask
//                     NSLeftMouseDownMask | NSLeftMouseUpMask | NSRightMouseDownMask | NSRightMouseUpMask |NSOtherMouseDownMask | NSOtherMouseUpMask
                                                           handler:self->handler];
}

- (void)stop {
    if (self->monitor) {
        [NSEvent removeMonitor:self->monitor];
        self->monitor = nil;
    }
}

- (void)activate:(BOOL)yes {
    self->active = yes;
}

- (BOOL)active {
    return self->active;
}

- (BOOL)modifierFlags:(NSEventModifierFlags)flags0 equalTo:(NSEventModifierFlags)flags1 {
    NSUInteger flagMask = NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask;
    return ((flags0 & flagMask) == (flags1 & flagMask));
}

const NSEventMask mouseEventMask = NSLeftMouseDownMask | NSLeftMouseUpMask | NSRightMouseDownMask | NSRightMouseUpMask |NSOtherMouseDownMask | NSOtherMouseUpMask;

static NSEventModifierFlags normalizeModifierFlags(NSEventModifierFlags flags) {
    return flags & (NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask);
}

static int countModifierFlags(NSEventModifierFlags flags) {
    int c = 0;
    c |= !!(flags & NSCommandKeyMask);
    c |= !!(flags & NSAlternateKeyMask);
    c |= !!(flags & NSControlKeyMask);
    c |= !!(flags & NSShiftKeyMask);
    return c;
}

- (void)installTimer:(EventHookItem)item withInterval:(NSTimeInterval) interval {
//    const NSTimeInterval interval = [NSEvent doubleClickInterval];
    NSValue* payload = [NSValue valueWithEventHookItem:&item];
    self->timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onTimerFired:) userInfo:payload repeats:NO];
}

- (void)onTimerFired:(NSTimer*)aTimer {
    NSTimeInterval timestamp = self->onGoingProxyEvent.timestamp;
    resetProxyEventProgress(&self->onGoingProxyEvent);
    self->onGoingProxyEvent.timestampAtTargetJobRun = timestamp + aTimer.timeInterval;
    NSValue* payload = aTimer.userInfo;
    const EventHookItem item = [payload eventHookItem];
    const CGEventFlags flags = (CGEventFlags)item.shortcutModifierFlags;
    postShortcutEvent(item.shortcutPlainKeyCode, flags);
}

- (ProxyEvent)detectProxyEventForMouseClick:(NSEvent*)event {
    ProxyEvent output;
    resetProxyEvent(&output);
    
    const MouseButtonType mouseBtnType = (uint32_t)event.buttonNumber + 1;
    output.fields.mouseBtnType = mouseBtnType;
    output.fields.modifierFlags = normalizeModifierFlags(event.modifierFlags);
    const OverallHooksInfo info = [self.hookStore overallHooksInfo];
    
    switch (event.clickCount) {
        case 0: // It is a long press event.
            output.fields.pressType = PressTypeLong;
            return output;
        case 3: // It is a triple click event
            // Remove an ongoing timer if any.
            [self->timer invalidate]; self->timer = nil;
            
            output.fields.pressType = PressTypeTriple;
            return output;
        case 2: // It is a double click event
            // Remove an ongoing timer if any.
            [self->timer invalidate]; self->timer = nil;
            
            output.fields.pressType = PressTypeDouble;
            
            // Do we have any of triple click hooks?
            if (info.maxClicks[mouseBtnType] == 3) {
                // Do we have a relevant hook?
                const EventHookItem* item = [_hookStore findHookItemMatching:output];
                if (item) {
                    // Then, kick a timer
                    [self installTimer:*item withInterval:[NSEvent doubleClickInterval]];
                }
                resetProxyEvent(&output);
            }
            // Otherwise, we're done.
            return output;
        case 1: // It is a single click event
            output.fields.pressType = PressTypeSingle;
            
            // Do we have any of double or triple click hooks?
            if (info.maxClicks[mouseBtnType] > 1) {
                // Do we have a relevant hook?
                const EventHookItem* item = [_hookStore findHookItemMatching:output];
                if (item) {
                    // Then, kick a timer
                    [self installTimer:*item withInterval:[NSEvent doubleClickInterval]];
                }
                resetProxyEvent(&output);
            }
            // Otherwise, we're done.
            return output;
            
        default:
            break;
    }
    
    resetProxyEvent(&output);
    return output;
}

- (ProxyEvent)detectProxyEventForMkm:(NSEvent*)event {
    ProxyEvent output;
    resetProxyEvent(&output);
    
    const NSTimeInterval pauseIntervalAfterPosting = 1.4f;
    const NSTimeInterval timestamp = event.timestamp;
    if (timestamp - self->onGoingProxyEvent.timestampAtTargetJobRun < pauseIntervalAfterPosting) {
        return output;
    }
    const NSEventModifierFlags flags = normalizeModifierFlags(event.modifierFlags);
    const CGKeyCode modifierKeyCode = event.keyCode;
    const OverallHooksInfo info = [self.hookStore overallHooksInfo];
    const int modifierCount = countModifierFlags(flags);
    const NSTimeInterval intervalLimit = 0.3;
    
    if (modifierCount == 0) { // The modifier key is up
        RT_ASSERT(self->onGoingProxyEvent.mkmCount % 2);
        ++self->onGoingProxyEvent.mkmCount;
    }
    else if (modifierCount == 1) { // The modifier key is down
        const BOOL resetTheState =
            // Exceeded the time interval limit between keystrokes?
            (timestamp - self->onGoingProxyEvent.timestamp > intervalLimit) ||
            // Another keystroke?
            (self->onGoingProxyEvent.modifierKeyCode != modifierKeyCode);
        self->onGoingProxyEvent.timestamp = timestamp;
        if (resetTheState) {
            self->onGoingProxyEvent.modifierKeyCode = modifierKeyCode;
            self->onGoingProxyEvent.modifierFlags = flags;
            self->onGoingProxyEvent.mkmCount = 0;
        }
        ++self->onGoingProxyEvent.mkmCount;
        return output;
    }
    else if (modifierCount > 1) { // Multiple modifier keys are down
        // MKM is only valid for a single modifier key. Reset all the state.
        resetProxyEventProgress(&self->onGoingProxyEvent);
        return output;
    }
    
    // We can be here only in case of key up.
    
    const ModifierKeyType modifierKeyType = modifierKeyTypeFromFlags(self->onGoingProxyEvent.modifierFlags);
    output.fields.modifierFlags = self->onGoingProxyEvent.modifierFlags;
    
    //<##>
    switch (self->onGoingProxyEvent.mkmCount/2) {
        case PressTypeQuadruple:
            // Remove an ongoing timer if any.
            [self->timer invalidate]; self->timer = nil;
            
            output.fields.pressType = PressTypeQuadruple;
            return output;
        case PressTypeTriple:
            // Remove an ongoing timer if any.
            [self->timer invalidate]; self->timer = nil;
            
            output.fields.pressType = PressTypeTriple;
            // Do we have any quadruple tap hook?
            if (info.maxTaps[modifierKeyType] > PressTypeTriple) {
                // Do we have a relevant hook?
                const EventHookItem* item = [_hookStore findHookItemMatching:output];
                if (item) {
                    // Then, kick a timer
                    [self installTimer:*item withInterval:intervalLimit];
                }
                resetProxyEvent(&output);
            }
            return output;
        case PressTypeDouble:
            output.fields.pressType = PressTypeDouble;
            // Do we have any of triple or quadruple tap hooks?
            if (info.maxTaps[modifierKeyType] > PressTypeDouble) {
                // Do we have a relevant hook?
                const EventHookItem* item = [_hookStore findHookItemMatching:output];
                if (item) {
                    // Then, kick a timer
                    [self installTimer:*item withInterval:intervalLimit];
                }
                resetProxyEvent(&output);
            }
            return output;
        default:
            break;
    }
    
    resetProxyEvent(&output);
    return output;
}

- (BOOL)handleHooks:(NSEvent*)event {
    if (self->active == NO)
        return NO;
    
    ProxyEvent prxEvt;
    const NSEventMask eventMask = NSEventMaskFromType(event.type);
    if (eventMask & mouseEventMask) {
        // Check if we have any of mouse clicking proxy events
        prxEvt = [self detectProxyEventForMouseClick:event];
    }
    else if (eventMask & NSFlagsChangedMask) {
        // Check if we have any of Multiple Keystrokes on Modifiers (MKM) proxy events
        prxEvt = [self detectProxyEventForMkm:event];
//        NSLog(@"modKeyCode=%d, tapUp=%d", self->onGoingProxyEvent.modifierKeyCode, self->onGoingProxyEvent.mkmCount);
    }

    const EventHookItem* item = [_hookStore findHookItemMatching:prxEvt];
    if (!item)
        return NO;

    // We have a matching target shortcut. Fire it!
    resetProxyEventProgress(&self->onGoingProxyEvent);
    self->onGoingProxyEvent.timestampAtTargetJobRun = event.timestamp;
    const CGEventFlags flags = (CGEventFlags)item->shortcutModifierFlags;
    postShortcutEvent(item->shortcutPlainKeyCode, flags);
    return YES;
}

@end
