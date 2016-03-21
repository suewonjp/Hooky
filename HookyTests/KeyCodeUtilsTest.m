//
//  HookyTests.m
//  HookyTests
//
//  Created by Suewon Bahng on 3/17/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KeyCodeUtils.h"
#import "TestUtils.h"

@interface KeyCodeUtilsTest : XCTestCase

@end

@implementation KeyCodeUtilsTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testKeyCodeToAndFromText {
    CGKeyCode keyCode = [TestUtils randomKeyCode];
    NSString* text = [KeyCodeUtils textFromKeyCode:keyCode];
    XCTAssert([text hasContent]);
    XCTAssertEqual(keyCode, [KeyCodeUtils keyCodeFromText:text]);
}

- (void)testModifierFlagsToAndFromText {
    NSString* text0 = [TestUtils randomModifierFlagsText];
    NSEventModifierFlags flags0 = [KeyCodeUtils modifierFlagsFromText:text0];
    NSString* text1 = [KeyCodeUtils textFromModifierFlags:flags0];
    NSEventModifierFlags flags1 = [KeyCodeUtils modifierFlagsFromText:text1];
    XCTAssertEqual(flags0, flags1);
}

- (void)testMethod_getKeyCode_keyText_flags_flagsText_fromText {
    CGKeyCode randomKeyCode = [TestUtils randomKeyCode];
    NSString* randomKeyCodeText = [KeyCodeUtils textFromKeyCode:randomKeyCode];
    XCTAssert([randomKeyCodeText hasContent]);
    NSString* randomModifierFlagsText = [TestUtils randomModifierFlagsText];
    NSString* text = [NSString stringWithFormat:@"%@ %@", randomModifierFlagsText, randomKeyCodeText];
    XCTAssert([text hasContent]);
    
    CGKeyCode keyCode = [KeyCodeUtils maxKeyCodes];
    NSString* keyText = nil;
    NSString* flagsText = nil;
    NSEventModifierFlags flags = 0;
    
    [KeyCodeUtils getKeyCode:&keyCode keyText:&keyText flags:&flags flagsText:&flagsText fromText:text];
    
    // Note that some keys (such as regular number keys and keypad number keys) have different key codes even if their character representations are same.
    // Thus following assertion is inapropriate.
//    XCTAssertEqual(keyCode, randomKeyCode);
    
    XCTAssertEqualObjects(keyText, randomKeyCodeText);
    XCTAssertEqual(flags, [KeyCodeUtils modifierFlagsFromText:randomModifierFlagsText]);
    XCTAssertEqualObjects(flagsText, [KeyCodeUtils textFromModifierFlags:flags]);
}

@end
