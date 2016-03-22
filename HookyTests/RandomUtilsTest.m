//
//  RandomUtilsTest.m
//  Hooky
//
//  Created by Suewon Bahng on 3/19/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RandomUtils.h"
#import "Utils.h"

@interface RandomUtilsTest : XCTestCase

@end

@implementation RandomUtilsTest

- (void)setUp {
    [super setUp];
    
    RUN_ONCE_BEGIN
    srand([NSDate timeIntervalSinceReferenceDate]);
    RUN_ONCE_END
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFunction_randomBetweenZeroAndOne {
    float value = randomBetweenZeroAndOne();
    XCTAssertGreaterThanOrEqual(value, .0f);
    XCTAssertLessThan(value, 1.0f);
}

- (void)testFunction_randomInteger {
    int lower = rand(), upper = rand();
    int value = randomInteger(lower, upper);
    if (upper < lower) {
        SWAP(upper, lower);
    }
    XCTAssertGreaterThanOrEqual(value, lower);
    XCTAssertLessThan(value, upper);
}

- (void)testFunction_randomFloat {
    float lower = rand(), upper = rand();
    float value = randomFloat(lower, upper);
    if (upper < lower) {
        SWAP(upper, lower);
    }
    XCTAssertGreaterThanOrEqual(value, lower);
    XCTAssertLessThan(value, upper);
}

@end
