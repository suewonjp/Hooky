//
//  TableRowContent.m
//  Hooky
//
//  Created by Suewon Bahng on 3/13/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "TableRowContent.h"
#import "Utils.h"
#import "KeyCodeUtils.h"
#import "EventDefinitions.h"

static NSString* mouseBtnNames[] = { @"NONE", @"MOUSE LEFT", @"MOUSE RIGHT", @"MOUSE MIDDLE" };

static NSString* keyPressTypeNames[] = { @"None", @"Click", @"Double Click/Tap", @"Triple Click/Tap", @"Quadruple Click/Tap", @"Long Press" };


@implementation TableRowContent

+ (NSUInteger)countMouseButtonNames {
    return COUNT_ARRAY_MEMBERS(mouseBtnNames);
}

+ (NSString*)mouseButtonNameAt:(NSUInteger)index {
    RT_ASSERT(index < [[self class] countMouseButtonNames]);
    return mouseBtnNames[index];
}

+ (NSUInteger)countKeyPressTypeNames {
    return COUNT_ARRAY_MEMBERS(keyPressTypeNames);
}

+ (NSString*)keyPressTypeNameAt:(NSUInteger)index {
    RT_ASSERT(index < [[self class] countKeyPressTypeNames]);
    return keyPressTypeNames[index];
}

- (instancetype)init {
    self = [super init];
    self.active = true;
    return self;
}

- (instancetype)initWithEventHookItem:(const struct EventHookItem*)item {
    self = [super init];
    [self proxyEventTypeWithMouseButtonIndex:item->proxyEvent.fields.mouseBtnType clickTypeIndex:item->proxyEvent.fields.pressType flags:item->proxyEvent.fields.modifierFlags];
    [self targetShortcutFromShorcutKeyCode:item->shortcutPlainKeyCode flags:item->shortcutModifierFlags];
    self.active = item->active;
    return self;
}

- (void)proxyEventTypeWithMouseButtonIndex:(NSInteger)mbIndex clickTypeIndex:(NSInteger)ctIndex flags:(NSEventModifierFlags)flags {
    NSString* mbName = [[self class] mouseButtonNameAt:mbIndex];
    NSString* ctName = [[self class] keyPressTypeNameAt:ctIndex];
    NSString* flagsText = [KeyCodeUtils textFromModifierFlags:flags];
    _proxyEventType =  [NSString stringWithFormat:@"%@ %@ %@", mbName, ctName, flagsText];
}

- (void)targetShortcutFromShorcutKeyCode:(CGKeyCode)code flags:(NSEventModifierFlags)flags {
    _targetShortcut = [NSString stringWithFormat:@"%@%@", [KeyCodeUtils textFromModifierFlags:flags], [KeyCodeUtils textFromKeyCode:code]];
}

@end
