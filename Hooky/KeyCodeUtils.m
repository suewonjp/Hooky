//
//  KeyCodeUtils.m
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/7/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "KeyCodeUtils.h"
#import <Carbon/Carbon.h>

@implementation KeyCodeUtils

+ (NSUInteger)maxKeyCodes {
    // The upper bound of the OS X virtual keys is 0x7f for now. (2016/03/07)
    return 0x7f;
}

+ (NSDictionary *)specialKeyCodeToTextMapping {
    static NSDictionary *mapping = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        mapping = @{
                    @(kVK_Command): @"⌘",
                    @(kVK_Option): @"⌥",
                    @(kVK_Control): @"⌃",
                    @(kVK_Shift): @"⇧",
                    @(kVK_F1): @"F1",
                    @(kVK_F2): @"F2",
                    @(kVK_F3): @"F3",
                    @(kVK_F4): @"F4",
                    @(kVK_F5): @"F5",
                    @(kVK_F6): @"F6",
                    @(kVK_F7): @"F7",
                    @(kVK_F8): @"F8",
                    @(kVK_F9): @"F9",
                    @(kVK_F10): @"F10",
                    @(kVK_F11): @"F11",
                    @(kVK_F12): @"F12",
                    @(kVK_F13): @"F13",
                    @(kVK_F14): @"F14",
                    @(kVK_F15): @"F15",
                    @(kVK_F16): @"F16",
                    @(kVK_F17): @"F17",
                    @(kVK_F18): @"F18",
                    @(kVK_F19): @"F19",
                    @(kVK_F20): @"F20",
                    @(kVK_Space): @"Space",
                    @(kVK_Delete): @"⌫",
                    @(kVK_ForwardDelete): @"⌦",
                    @(kVK_ANSI_KeypadClear): @"⌧",
                    @(kVK_LeftArrow): @"←",
                    @(kVK_RightArrow): @"→",
                    @(kVK_UpArrow): @"↑",
                    @(kVK_DownArrow): @"↓",
                    @(kVK_End): @"↘",
                    @(kVK_Home): @"↖",
                    @(kVK_Escape): @"⎋",
                    @(kVK_PageDown): @"⇟",
                    @(kVK_PageUp): @"⇞",
                    @(kVK_Return): @"↩",
                    @(kVK_ANSI_KeypadEnter): @"⌅",
                    @(kVK_Tab): @"⇥",
                    @(kVK_Help): @"?⃝"
                    };
    });
    return mapping;
}

+ (NSString *)textFromSpecialKeyCode:(CGKeyCode) keyCode {
    NSNumber* keyCodeNumber = [NSNumber numberWithInt:keyCode];
    return [[self class] specialKeyCodeToTextMapping][keyCodeNumber];
}

+ (NSString *)textFromSpecialKeyCodeWrappedByNumber:(NSNumber*) keyCodeNumber {
    return [[self class] specialKeyCodeToTextMapping][keyCodeNumber];
}

+ (NSDictionary *)plainKeyCodeToTextMapping {
    static dispatch_once_t token;
    static NSMutableDictionary *mapping = nil;
    dispatch_once(&token, ^{
        TISInputSourceRef tisSource = TISCopyCurrentKeyboardLayoutInputSource();
        if (!tisSource)
            return;
        CFDataRef layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
        CFRelease(tisSource);
        const UCKeyboardLayout *keyLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
        
        // The upper bound of the OS X virtual keys is 0x7f for now. (2016/03/07)
        const NSUInteger upperBounds = [[self class] maxKeyCodes];
        mapping = [NSMutableDictionary dictionaryWithCapacity:upperBounds];
        
        for (uint16_t i=0; i<upperBounds; ++i) {
            const UniCharCount maxBuf = 128;
            UniChar ch[maxBuf];
            CGKeyCode code = i;
            UniCharCount actualCount = 0;
            UInt32 deadKeyState = 0;
            OSStatus err = UCKeyTranslate(keyLayout,
                                          code,
                                          kUCKeyActionDisplay,
                                          0,
                                          LMGetKbdType(),
                                          kUCKeyTranslateNoDeadKeysBit,
                                          &deadKeyState,
                                          maxBuf,
                                          &actualCount,
                                          ch);
            if (err != noErr)
                return;
            
            NSNumber* keyCodeNumber = [NSNumber numberWithInt:code];
            NSString* text = [[self class] textFromSpecialKeyCodeWrappedByNumber:keyCodeNumber];
            if (text)
                continue;
            text = [NSString stringWithCharacters:ch length:actualCount].uppercaseString;
            [mapping setObject:text forKey:keyCodeNumber];
        }
    });
    return mapping;
}

+ (NSString*)textFromKeyCode:(CGKeyCode)keyCode {
    NSNumber* keyCodeNumber = [NSNumber numberWithInt:keyCode];
    NSString* text = [[self class] textFromSpecialKeyCodeWrappedByNumber:keyCodeNumber];
    if (text)
        return text;
    return [[self class] plainKeyCodeToTextMapping][keyCodeNumber];
}

+ (NSDictionary*)textToKeyCodeMapping {
    static dispatch_once_t token;
    static NSMutableDictionary *mapping = nil;
    dispatch_once(&token, ^{
        NSDictionary* plainKeyMapping = [[self class] plainKeyCodeToTextMapping];
        NSDictionary* specialKeyMapping = [[self class] specialKeyCodeToTextMapping];
        const NSUInteger upperBounds = plainKeyMapping.count + specialKeyMapping.count;
        mapping = [NSMutableDictionary dictionaryWithCapacity:upperBounds];
        
        for (NSNumber* key in plainKeyMapping.allKeys) {
            NSString* text = plainKeyMapping[key];
            [mapping setObject:key forKey:text];
        }
        
        for (NSNumber* key in specialKeyMapping.allKeys) {
            NSString* text = specialKeyMapping[key];
            [mapping setObject:key forKey:text];
        }
    });
    return mapping;
}

+ (CGKeyCode)keyCodeFromText:(NSString*)text {
    NSNumber* keyCodeNumber = [[self class] textToKeyCodeMapping][text];
    return [keyCodeNumber unsignedShortValue];
}

+ (NSString*)textFromModifierFlags:(NSEventModifierFlags)f {
    return [NSString stringWithFormat:@"%@%@%@%@",
            (f & NSControlKeyMask ? @"⌃" : @""),
            (f & NSAlternateKeyMask ? @"⌥" : @""),
            (f & NSShiftKeyMask ? @"⇧" : @""),
            (f & NSCommandKeyMask ? @"⌘" : @"")];
}

+ (NSEventModifierFlags)modifierFlagsFromText:(NSString*)text {
    NSEventModifierFlags output = 0;
    if ([text containsString:@"⌘"])
        output |= NSCommandKeyMask;
    if ([text containsString:@"⌥"])
        output |= NSAlternateKeyMask;
    if ([text containsString:@"⌃"])
        output |= NSControlKeyMask;
    if ([text containsString:@"⇧"])
        output |= NSShiftKeyMask;
    return output;
}

+ (NSString*)findPlainKeyTextFrom:(NSString*)text {
    NSUInteger c = text.length;
    unichar* buf = (unichar*)malloc(sizeof(*buf)*c);
    NSUInteger len = 0;
    for (NSUInteger i=0; i<c; ++i) {
        unichar ch = [text characterAtIndex:i];
        // ⌘ Command: U+2318
        // ⌥ Option: U+2325
        // ⌃ Control: U+2303
        // ⇧ Shift: U+21E7
        if (isspace(ch) || ch == 0x2318 || ch == 0x2325 || ch == 0x2303 || ch == 0x21e7)
            continue;
        buf[len++] = ch;
    }
    
    NSMutableString* output = [NSMutableString stringWithCharacters:buf length:len];
    free(buf);
    return output;
}

+ (void)getKeyCode:(CGKeyCode*)outKeyCode
           keyText:(NSString**)outKeyText
             flags:(NSEventModifierFlags*)outFlags
         flagsText:(NSString**)outFlagsText
          fromText:(NSString*)inText {
    NSString* keyText = [[self class] findPlainKeyTextFrom:inText];
    if (outKeyText) {
        *outKeyText = keyText;
    }
    if (outKeyCode) {
        *outKeyCode = [[self class] keyCodeFromText:keyText];
    }
    NSEventModifierFlags flags = [[self class] modifierFlagsFromText:inText];
    if (outFlags) {
        *outFlags = flags;
    }
    if (outFlagsText) {
        *outFlagsText = [[self class] textFromModifierFlags:flags];
    }
}

@end
