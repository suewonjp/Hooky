//
//  EventHookStoreTest.m
//  Hooky
//
//  Created by Suewon Bahng on 3/19/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestUtils.h"
#import "EventHookStore.h"

@interface EventHookStoreTest : XCTestCase {
    EventHookStore* hookStore;
}

@end

@implementation EventHookStoreTest

- (void)setUp {
    [super setUp];
    
    self->hookStore = [[EventHookStore alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInsertingHook {
    for (int i=0; i<3; ++i) {
        const EventHookItem item = [TestUtils randomEventHookItem];
        const EventHookItem* returnedItem = [self->hookStore setHook:&item at:-1];
        XCTAssert(returnedItem && [self->hookStore countHooks] == i+1);
        XCTAssert(&item != returnedItem);
        XCTAssertEqual(memcmp(&item, returnedItem, sizeof(item)), 0);
    }
    
    {
        const NSUInteger c = [self->hookStore countHooks];
        const EventHookItem item = [TestUtils randomEventHookItem];
        const int indexToUpdate = randomInteger(0, (int)[self->hookStore countHooks]);
        const EventHookItem* returnedItem = [self->hookStore setHook:&item at:indexToUpdate];
        XCTAssert(returnedItem && [self->hookStore countHooks] == c);
        XCTAssert(&item != returnedItem);
        XCTAssertEqual(memcmp(&item, returnedItem, sizeof(item)), 0);
    }
}

- (void)testRemovingHook {
    const EventHookItem items[] = {
        [TestUtils randomEventHookItem],
        [TestUtils randomEventHookItem],
        [TestUtils randomEventHookItem],
        [TestUtils randomEventHookItem],
        [TestUtils randomEventHookItem],
    };
    
    const int c = COUNT_ARRAY_MEMBERS(items);
    
    for (int i=0; i<c; ++i) {
        [self->hookStore setHook:items+i at:-1];
    }
    XCTAssertEqual([self->hookStore countHooks], c);
    
    const int indexToRemove = randomInteger(0, c);
    [self->hookStore removeHookAt:indexToRemove];
    XCTAssertEqual([self->hookStore countHooks], c - 1);
    
    for (int i=0; i<c; ++i) {
        if (i == indexToRemove)
            continue;
        const EventHookItem* foundItem = [self->hookStore findHookItemMatching:items[i].proxyEvent];
        XCTAssert(foundItem);
        XCTAssertEqual(memcmp(foundItem, items + i, sizeof(*foundItem)), 0);
    }
}

- (void)testTurningHook {
    const EventHookItem item = [TestUtils randomEventHookItem];
    EventHookItem tmp0 = *[self->hookStore setHook:&item at:-1];
    XCTAssertEqual(tmp0.active, true);
    [self->hookStore turnHookAt:[self->hookStore countHooks]-1 asActive:false];
    EventHookItem tmp1 = *[self->hookStore lastHook];
    XCTAssertNotEqual(tmp0.active, tmp1.active);
    [self->hookStore turnHookAt:[self->hookStore countHooks]-1 asActive:true];
    EventHookItem tmp2 = *[self->hookStore lastHook];
    XCTAssertNotEqual(tmp2.active, tmp1.active);
}

- (void)testSerialization {
    const int c = 5;
    for (int i=0; i<c; ++i) {
        const EventHookItem item = [TestUtils randomEventHookItem];
        if ([self->hookStore findHookItemMatching:item.proxyEvent] == NULL) {
            [self->hookStore setHook:&item at:-1];
        }
    }
    
    NSMutableDictionary* dict0 = [NSMutableDictionary dictionary];
    [self->hookStore toDictionary:dict0];
    
    while ([self->hookStore countHooks]) {
        [self->hookStore removeHookAt:0];
    }
    
    [self->hookStore fromDictionary:dict0];
    
    NSMutableDictionary* dict1 = [NSMutableDictionary dictionary];
    [self->hookStore toDictionary:dict1];
    
    XCTAssertEqualObjects(dict0, dict1);
}

- (void)testFastCheck {
    {
        const EventHookItem item = {
            {
                MouseButtonTypeMiddle,
                PressTypeSingle,
                0,
                0
            },
            [TestUtils randomModifierFlags],
            randomInteger(0, [TestUtils randomKeyCode]),
            true
        };
        [self->hookStore setHook:&item at:-1];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    } // count = 1
    {
        const EventHookItem item = {
            {
                MouseButtonTypeLeft,
                PressTypeDouble,
                0,
                0
            },
            [TestUtils randomModifierFlags],
            randomInteger(0, [TestUtils randomKeyCode]),
            true
        };
        [self->hookStore setHook:&item at:-1];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    } // count = 2
    {
        const EventHookItem item = {
            {
                MouseButtonTypeRight,
                PressTypeLong,
                0,
                0
            },
            [TestUtils randomModifierFlags],
            randomInteger(0, [TestUtils randomKeyCode]),
            true
        };
        [self->hookStore setHook:&item at:-1];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 1);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    } // count = 3
    {
        [self->hookStore turnHookAt:1 asActive:false];
        [self->hookStore turnHookAt:0 asActive:false];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 1);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 0);
    }
    {
        [self->hookStore turnHookAt:1 asActive:true];
        [self->hookStore turnHookAt:0 asActive:true];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 1);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    }
    {
        [self->hookStore removeHookAt:2];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    } // count = 2
    {
        const EventHookItem item = {
            {
                MouseButtonTypeMiddle,
                PressTypeTriple,
                0,
                0
            },
            [TestUtils randomModifierFlags],
            randomInteger(0, [TestUtils randomKeyCode]),
            true
        };
        [self->hookStore setHook:&item at:-1];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 0);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 3);
    } // count = 3
    {
        EventHookItem item = *[self->hookStore lastHook];
        item.proxyEvent.fields.mouseBtnType = MouseButtonTypeRight;
        [self->hookStore setHook:&item at:2];
        const OverallHooksInfo overallHooksInfo = [self->hookStore overallHooksInfo];
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeLeft], 2);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeRight], 3);
        XCTAssertEqual(overallHooksInfo.maxClicks[MouseButtonTypeMiddle], 1);
    }
}

@end
