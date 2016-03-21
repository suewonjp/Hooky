//
//  KeyCodeUtils.h
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/7/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyCodeUtils : NSObject

+ (NSUInteger)maxKeyCodes;

+ (NSString *)textFromSpecialKeyCode:(CGKeyCode)keyCode;

+ (NSString*)textFromKeyCode:(CGKeyCode)keyCode;

+ (CGKeyCode)keyCodeFromText:(NSString*)text;

+ (NSString*)textFromModifierFlags:(NSEventModifierFlags)f;

+ (NSEventModifierFlags)modifierFlagsFromText:(NSString*)text;

+ (void)getKeyCode:(CGKeyCode*)outKeyCode
           keyText:(NSString**)outKeyText
             flags:(NSEventModifierFlags*)outFlags
         flagsText:(NSString**)outFlagsText
          fromText:(NSString*)inText;

@end
