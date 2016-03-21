//
//  EventHookItem.h
//  Hooky
//
//  Created by Suewon Bahng on 3/10/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#ifndef EventHookItem_h
#define EventHookItem_h

#include <sys/types.h>

typedef struct EventHookItem {
    uint32_t    proxyModifierFlags;
    uint16_t    proxyEventType;
    uint16_t    shortcutPlainKeyCode;
    uint32_t    shortcutModifierFlags;
    uint8_t     active;
    uint8_t     reserved[3];
} EventHookItem;

#endif /* EventHookItem_h */
