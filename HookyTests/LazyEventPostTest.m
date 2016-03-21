//
//  LazyEventPostTest.m
//  Hooky
//
//  Created by Suewon Bahng on 3/20/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestUtils.h"
#import "EventHookManager.h"

//
// NSNumber + ProxyEvent
//
@interface NSNumber (ProxyEvent)
+ (instancetype)numberWithProxyEvent:(ProxyEvent)rawData;
- (ProxyEvent)decodeToProxyEvent;
@end

@implementation NSNumber (ProxyEvent)
+ (instancetype)numberWithProxyEvent:(ProxyEvent)rawData {
    return [NSNumber numberWithUnsignedLongLong:rawData.value];
}

- (ProxyEvent)decodeToProxyEvent {
    unsigned long long value = [self unsignedLongLongValue];
    ProxyEvent prxEvt;
    CT_ASSERT(sizeof(value) == sizeof(prxEvt));
    prxEvt.value = value;
    return prxEvt;
}
@end

@interface LazyEventPostTest : XCTestCase {
    EventHookItem   payloadItem;
}

@end

@implementation LazyEventPostTest

- (void)setUp {
    [super setUp];
    
    self->payloadItem = [TestUtils randomEventHookItem];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testProxyEventCoder {
    EventHookItem item = [TestUtils randomEventHookItem];
    NSNumber* encoded = [NSNumber numberWithProxyEvent:item.proxyEvent];
    XCTAssert(encoded);
    ProxyEvent prxEvt = [encoded decodeToProxyEvent];
    XCTAssertEqual(item.proxyEvent.value, prxEvt.value);
}

- (void)testEventHookItemCoder {
    EventHookItem item = [TestUtils randomEventHookItem];
    NSValue* encoded = [NSValue valueWithEventHookItem:&item];
    XCTAssert(encoded);
    EventHookItem decoded = [encoded eventHookItem];
    XCTAssertEqual(memcmp(&item, &decoded, sizeof(item)), 0);
}

- (void)onTimerFired:(NSTimer*)aTimer {
    TYPE_ASSERT(NSArray, aTimer.userInfo);
    NSArray* payload = aTimer.userInfo;
    XCTAssertNotNil(payload);
    XCTAssertEqual(payload.count, 2);
    [(XCTestExpectation*)payload[0] fulfill];
    EventHookItem deliveredItem = [(NSValue*)payload[1] eventHookItem];
    XCTAssertEqual(memcmp(&deliveredItem, &self->payloadItem, sizeof(deliveredItem)), 0);
}

- (void)testTimer {
    const NSTimeInterval interval = [NSEvent doubleClickInterval];
    NSValue* value = [NSValue valueWithEventHookItem:&self->payloadItem];
    XCTAssert(value);
    
    XCTestExpectation* timerFireExpectation = [self expectationWithDescription:@"Timer Fire"];
    
    NSArray* payload = @[ timerFireExpectation, value ];
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onTimerFired:) userInfo:payload repeats:NO];
    XCTAssert(timer);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

@end
