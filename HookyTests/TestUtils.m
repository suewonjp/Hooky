//
//  EventHookStore.h
//  Hooky
//
//  Created by Suewon Bahng on 3/19/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "TestUtils.h"
#import "KeyCodeUtils.h"

@interface TestUtils () {
}

@end


@implementation TestUtils

+ (CGKeyCode)randomKeyCode {
    NSInteger maxKeyCodes = [KeyCodeUtils maxKeyCodes];
    CGKeyCode keyCode = rand() % maxKeyCodes;
    return  keyCode;
}

+ (NSString*)textFromRandomKeyCode {
    NSString* text = [KeyCodeUtils textFromKeyCode:[self randomKeyCode]];
    return text;
}

+ (NSEventModifierFlags)randomModifierFlags {
    NSEventModifierFlags f = 0;
    const NSEventModifierFlags masks[] = {
        NSCommandKeyMask, NSAlternateKeyMask, NSControlKeyMask, NSShiftKeyMask
    };
    const int c = COUNT_ARRAY_MEMBERS(masks);
    for (int i=0; i<c; ++i) {
        if (rand() % 2) {
            f |= masks[i];
        }
    }
    return f;
}

+ (NSString*)randomModifierFlagsText {
    //    return [KeyCodeUtils textFromModifierFlags:[self randomModifierFlags]];
    NSString* modifierFlagsCharacters[] = { @"⌘", @"⇧", @"⌥", @"⌃", };
    const int c = COUNT_ARRAY_MEMBERS(modifierFlagsCharacters);
    NSMutableString* text = [NSMutableString stringWithString:@""];
    for (int i=0; i<c; ++i) {
        if (rand() % 2) {
            [text appendString:modifierFlagsCharacters[i]];
        }
    }
    return text;
}

+ (EventHookItem)randomEventHookItem {
    EventHookItem output = {
        {
            randomInteger(MouseButtonTypeLeft, EndOfMouseButtonType),
            randomInteger(PressTypeNone, EndOfPressType),
            0,
            [TestUtils randomModifierFlags]
        },
        [TestUtils randomModifierFlags],
        [TestUtils randomKeyCode],
        true,
    };
    return  output;
}

+ (BOOL)createFolder:(NSString*)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    return [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (void)deleteFolder:(NSString*)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *contents = [manager contentsOfDirectoryAtPath:path
                                                     error:nil];
    
    for (NSString *fileName in contents) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        
        [manager removeItemAtPath:filePath error:nil];
    }
    
    [manager removeItemAtPath:path error:nil];
}

@end