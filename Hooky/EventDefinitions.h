//
//  EventDefinitions.h
//  Hooky
//
//  Created by Suewon Bahng on 3/14/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#ifndef EventDefinitions_h
#define EventDefinitions_h

#import <sys/types.h>
#import "MacroTools.h"

typedef enum : int8_t {
    MouseButtonTypeNone,
    MouseButtonTypeLeft,
    MouseButtonTypeRight,
    MouseButtonTypeMiddle,
    EndOfMouseButtonType
} MouseButtonType;

static inline BOOL isMouseClickEvent(MouseButtonType type) {
    return (MouseButtonTypeNone < type && type < EndOfMouseButtonType);
}

typedef enum : int8_t {
    ModifierKeyTypeCommand,
    ModifierKeyTypeOption,
    ModifierKeyTypeControl,
    ModifierKeyTypeShift,
    EndOfModifierKeyType,
} ModifierKeyType;

typedef enum : int8_t {
    PressTypeNone,
    PressTypeSingle,
    PressTypeDouble,
    PressTypeTriple,
    PressTypeQuadruple,
    PressTypeLong,
    EndOfPressType,
} PressType;

typedef union ProxyEvent {
    struct {
        uint32_t mouseBtnType   : 8;
        uint32_t pressType      : 8;
        uint32_t reserved       : 16;
        uint32_t modifierFlags;
    } fields;
    uint64_t value;
} ProxyEvent;

CT_ASSERT(sizeof(ProxyEvent) <= sizeof(uint64_t));
CT_ASSERT(sizeof(ProxyEvent) <= sizeof(unsigned long long));

static inline void resetProxyEvent(ProxyEvent* evtState) {
    evtState->value = 0;
}

static inline void copyProxyEvent(const ProxyEvent* src, ProxyEvent* dst) {
    dst->value = src->value;
}

static inline int8_t countMouseClicks(const ProxyEvent* prxEvt) {
    if (isMouseClickEvent(prxEvt->fields.mouseBtnType)) {
        if (PressTypeNone < prxEvt->fields.pressType && prxEvt->fields.pressType < PressTypeLong)
            return prxEvt->fields.pressType;
        if (prxEvt->fields.pressType == PressTypeLong)
            return 1;
    }
    return 0;
}

static inline int8_t countTaps(const ProxyEvent* prxEvt) {
    if (!isMouseClickEvent(prxEvt->fields.mouseBtnType)) {
        if (PressTypeSingle < prxEvt->fields.pressType && prxEvt->fields.pressType < PressTypeLong)
            return prxEvt->fields.pressType;
    }
    return 0;
}

typedef struct EventHookItem {
    ProxyEvent  proxyEvent;
    uint32_t    shortcutModifierFlags;
    uint16_t    shortcutPlainKeyCode;
    uint8_t     active;
    uint8_t     reserved;
} EventHookItem;

CT_ASSERT(sizeof(EventHookItem) <= 16);


#endif /* EventDefinitions_h */
