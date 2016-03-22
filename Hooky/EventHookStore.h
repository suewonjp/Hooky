//
//  EventHookStore.h
//  Hooky
//
//  Created by Suewon Bahng on 3/18/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDefinitions.h"

typedef struct OverallHooksInfo {
    uint8_t maxClicks[EndOfMouseButtonType];
    uint8_t maxTaps[EndOfModifierKeyType];
} OverallHooksInfo;

CT_ASSERT(sizeof(OverallHooksInfo) <= 8);


ModifierKeyType modifierKeyTypeFromFlags(uint64_t flags);


@interface EventHookStore : NSObject

- (const EventHookItem*)findHookItemMatching:(ProxyEvent)prxEvt;

- (const EventHookItem*)setHook:(const EventHookItem*)hookItem at:(NSInteger)index;

- (void)removeHookAt:(NSInteger)index;

- (void)turnHookAt:(NSInteger)index asActive:(BOOL)yes;

- (const EventHookItem*)hookAt:(NSInteger)index;

- (const EventHookItem*)lastHook;

- (NSUInteger)countHooks;

- (OverallHooksInfo)overallHooksInfo;

- (void)toDictionary:(NSMutableDictionary*)dictionary;

- (void)fromDictionary:(NSDictionary*)dictionary;

@end
