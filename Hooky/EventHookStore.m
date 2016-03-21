//
//  EventHookStore.m
//  Hooky
//
//  Created by Suewon Bahng on 3/18/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "EventHookStore.h"
#import "Utils.h"
#import "EventDefinitions.h"
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

typedef union OverallHooksInfoWrapper {
    OverallHooksInfo    info;
    uint64_t            value;
} OverallHooksInfoWrapper;


ModifierKeyType modifierKeyTypeFromFlags(uint64_t flags) {
    if (flags & NSCommandKeyMask)
        return ModifierKeyTypeCommand;
    if (flags & NSAlternateKeyMask)
        return ModifierKeyTypeOption;
    if (flags & NSControlKeyMask)
        return ModifierKeyTypeControl;
    if (flags & NSShiftKeyMask)
        return ModifierKeyTypeShift;
    return EndOfModifierKeyType;
}


@interface EventHookStore () {
    OverallHooksInfoWrapper overallHooksInfo;
    NSPointerArray*         hookItems;
}

@end

@implementation EventHookStore

static NSUInteger sizeOfEventHookItem(const void *item) {
    return sizeof(EventHookItem);
}

- (instancetype)init {
    self = [super init];
    
    NSPointerFunctions* ptrFunc = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsMallocMemory | NSPointerFunctionsStructPersonality | NSPointerFunctionsCopyIn];
    ptrFunc.sizeFunction = &sizeOfEventHookItem;
    self->hookItems = [NSPointerArray                         pointerArrayWithPointerFunctions:ptrFunc];
    
    return self;
}

- (void)updateOverallHooksInfo {
    self->overallHooksInfo.value = 0;
    const NSUInteger c = self->hookItems.count;
    for (NSUInteger i=0; i<c; ++i) {
        const EventHookItem* item = [self hookAt:i];
        if (!item->active)
            continue;
        
        const int clickCount = countMouseClicks(&item->proxyEvent);
        self->overallHooksInfo.info.maxClicks[item->proxyEvent.fields.mouseBtnType] = MAX2(self->overallHooksInfo.info.maxClicks[item->proxyEvent.fields.mouseBtnType], clickCount);
        
        const ModifierKeyType modifierKeyType = modifierKeyTypeFromFlags(item->proxyEvent.fields.modifierFlags);
        
        const int tapCount = countTaps(&item->proxyEvent);
        self->overallHooksInfo.info.maxTaps[modifierKeyType] = MAX2(self->overallHooksInfo.info.maxTaps[modifierKeyType], tapCount);
    }
}

- (const EventHookItem*)findHookItemMatching:(ProxyEvent)prxEvt {
    if (prxEvt.value == 0)
        return NULL;
    for (int i=0; i<self->hookItems.count; ++i) {
        const EventHookItem* item = (EventHookItem*)[self->hookItems pointerAtIndex:i];
        if (!item->active)
            continue;
        if (prxEvt.value == item->proxyEvent.value)
            return item;
    }
    return NULL;
}

- (const EventHookItem*)setHook:(const EventHookItem*)hookItem at:(NSInteger)index {
    RT_ASSERT(hookItem && index < (NSInteger)self->hookItems.count);
    EventHookItem* slot = nil;
    if (index == -1) {
        // Create a new item
        [self->hookItems addPointer:(void*)hookItem];
        slot = (EventHookItem*)[self->hookItems pointerAtIndex:self->hookItems.count-1];
    }
    else {
        // Update an existing item
        slot = (EventHookItem*)[self->hookItems pointerAtIndex:index];
        *slot = *hookItem;
    }
    [self updateOverallHooksInfo];
    return slot;
}

- (void)removeHookAt:(NSInteger)index {
    RT_ASSERT(-1 < index && index < self->hookItems.count);
    [self->hookItems removePointerAtIndex:index];
    [self updateOverallHooksInfo];
}

- (void)turnHookAt:(NSInteger)index asActive:(BOOL)yes {
    RT_ASSERT(-1 < index && index < self->hookItems.count);
    EventHookItem* item = (EventHookItem*)[self->hookItems pointerAtIndex:index];
    item->active = yes;
    [self updateOverallHooksInfo];
}

- (const EventHookItem*)hookAt:(NSInteger)index {
    RT_ASSERT(-1 < index && index < self->hookItems.count);
    return (const EventHookItem*)[self->hookItems pointerAtIndex:index];
}

- (const EventHookItem*)lastHook {
    const NSUInteger c = self->hookItems.count;
    if (!c)
        return NULL;
    return (const EventHookItem*)[self->hookItems pointerAtIndex:(c - 1)];
}

- (NSUInteger)countHooks {
    return self->hookItems.count;
}

- (OverallHooksInfo)overallHooksInfo {
    return self->overallHooksInfo.info;
}

static NSString* eventHookItemFieldNames[] = {
    @"prxEvtMsBtnType",
    @"prxEvtPrsType",
    @"prxEvtModFlags",
    @"scPlnKeyCode",
    @"scModFlags",
    @"active",
};

+ (NSDictionary*)dictionaryFromHookItem:(EventHookItem*)item {
    return @{
             eventHookItemFieldNames[0]:@(item->proxyEvent.fields.mouseBtnType),
             eventHookItemFieldNames[1]:@(item->proxyEvent.fields.pressType),
             eventHookItemFieldNames[2]:@(item->proxyEvent.fields.modifierFlags),
             eventHookItemFieldNames[3]:@(item->shortcutPlainKeyCode),
             eventHookItemFieldNames[4]:@(item->shortcutModifierFlags),
             eventHookItemFieldNames[5]:@(item->active),
             };
}

+ (void)fromDictionary:(NSDictionary*)dictionary toHookItem:(EventHookItem*)item {
    NSString* __strong *key = eventHookItemFieldNames;
    item->proxyEvent.fields.mouseBtnType =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
    item->proxyEvent.fields.pressType =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
    item->proxyEvent.fields.modifierFlags =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
    item->shortcutPlainKeyCode =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
    item->shortcutModifierFlags =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
    item->active =
    [(NSNumber*)[dictionary objectForKey:*key++] unsignedIntValue];
}

const static int CURRENT_FORMAT_VERSION = 1;

+ (void)writeFormatVersionTo:(NSMutableDictionary*)dictionary {
    NSNumber* n = [NSNumber numberWithInt:CURRENT_FORMAT_VERSION];
    [dictionary setObject:n forKey:@"hkFmtVer"];
}

- (void)toDictionary:(NSMutableDictionary*)dictionary {
    NSMutableArray* items = [NSMutableArray array];
    NSUInteger c = self->hookItems.count;
    for (NSUInteger i=0; i<c; ++i) {
        EventHookItem* item = (EventHookItem*)[self->hookItems pointerAtIndex:i];
        [items addObject:[[self class] dictionaryFromHookItem:item]];
    }
    [dictionary setObject:items forKey:@"hookItems"];
    
    [[self class] writeFormatVersionTo:dictionary];
}

- (void)fromDictionary:(NSDictionary*)dictionary {
    NSMutableArray* items = [dictionary objectForKey:@"hookItems"];
    NSUInteger c = items.count;
    for (NSUInteger i=0; i<c; ++i) {
        NSDictionary* d = items[i];
        EventHookItem item = { 0 };
        [[self class] fromDictionary:d toHookItem:&item];
        [self->hookItems addPointer:&item];
    }
    [self updateOverallHooksInfo];
}

@end
