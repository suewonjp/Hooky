//
//  Util.m
//  HelloWorld
//
//  Created by Suewon Bahng on 5/27/14.
//  Copyright (c) 2014 bsw_corporation. All rights reserved.
//

#import "Utils.h"
#import <Cocoa/Cocoa.h>

@implementation Utils

+ (void)alert:(NSString*)msg
     withInfo:(NSString*)info
     withIcon:(NSString*)unicodeIcon
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    NSString* icon = unicodeIcon ? unicodeIcon : @"\u26a0\ufe0f";
    [alert setMessageText:[NSString stringWithFormat:@"%@ %@", icon, msg]];
    if (info) [alert setInformativeText:info];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert.window orderFrontRegardless];
    [alert runModal];
}

+ (BOOL)ask:(NSString*)question
   withInfo:(NSString*)info
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"YES"];
    [alert addButtonWithTitle:@"NO"];
    NSString* icon = @"\u2049\ufe0f";
    [alert setMessageText:[NSString stringWithFormat:@"%@ %@", icon, question]];
    if (info) [alert setInformativeText:info];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert.window orderFrontRegardless];
    if ([alert runModal] == NSAlertFirstButtonReturn)
        return YES;
    return NO;
}

@end

@implementation NSString (hasContent)

- (BOOL)blank {
    if (!self.length)
        return YES;
    return ![self stringByTrimmingCharactersInSet:[NSCharacterSet
                                           whitespaceAndNewlineCharacterSet]].length;
}

- (BOOL)hasContent {
    return ![self blank];
}

@end
