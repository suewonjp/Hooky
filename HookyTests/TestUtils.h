//
//  EventHookStore.h
//  Hooky
//
//  Created by Suewon Bahng on 3/19/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Utils.h"
#import "RandomUtils.h"
#import "EventDefinitions.h"

@interface TestUtils : NSObject

+ (CGKeyCode)randomKeyCode;

+ (NSString*)textFromRandomKeyCode;

+ (NSEventModifierFlags)randomModifierFlags;

+ (NSString*)randomModifierFlagsText;

+ (EventHookItem)randomEventHookItem;

+ (BOOL)createFolder:(NSString*)path;

+ (void)deleteFolder:(NSString*)path;

@end