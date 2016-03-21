//
//  ShortcutView.m
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/1/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "ShortcutView.h"
#import "KeyCodeUtils.h"
#import "Utils.h"
#import <Carbon/Carbon.h>

const static NSEventModifierFlags defaultModifierKeyMask =
    NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask;

@interface ShortcutView () {
    ushort               keyCode;
    NSString*            keyText;
    NSEventModifierFlags modifierFlags;
    BOOL                 active;
    BOOL                 clearable;
    BOOL                 bound;
    BOOL                 keyByKey;
}

#pragma mark Properties
@property (nonatomic) NSRect clearButtonRect;

@end

@implementation ShortcutView

#pragma mark Initializaton/Deinitialization

- (instancetype)initWithFrame:(NSRect)aFrameRect {
    self = [super initWithFrame:aFrameRect];
    
    [self clearShortcut];
    
    self->active = NO;
    self->keyByKey = NO;
    
    return self;
}

#pragma mark Getters/Setters

- (NSString*)stringValue {
    NSString* outputFlagText = [KeyCodeUtils textFromModifierFlags:self->modifierFlags];
    return [NSString stringWithFormat:@"%@%@", outputFlagText, self->keyText];
}

- (void)setStringValue:(NSString *)stringValue {
    if (stringValue == nil) {
        [self unbindShortcut];
        return;
    }

    CGKeyCode kc = 0;
    NSString* kt = nil;
    NSEventModifierFlags f = 0;
    [KeyCodeUtils getKeyCode:&kc keyText:&kt flags:&f flagsText:nil fromText:stringValue];
    [self bindShortcutForKey:kc keyText:kt Flags:f];
}

- (void)setPersistanceKey:(NSString*)key {
    if ([self->_persistanceKey isEqualToString:key])
        return;
    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    self->_persistanceKey = key;
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    id value = [ud objectForKey:key];
    if (value == nil)
        return;
    TYPE_ASSERT(NSArray, value);
    NSArray* arrValue = value;
    RT_ASSERT(arrValue.count == 3);
    TYPE_ASSERT(NSNumber, arrValue[0]);
    TYPE_ASSERT(NSString, arrValue[1]);
    TYPE_ASSERT(NSNumber, arrValue[2]);
    NSNumber* kc = arrValue[0];
    NSNumber* flags = arrValue[2];
    [self bindShortcutForKey:[kc unsignedShortValue] keyText:arrValue[1] Flags:[flags unsignedIntegerValue]];
}

#pragma mark Custom Methods

NSString* unicharToString(unichar aChar)
{
    return [NSString stringWithFormat: @"%C", aChar];
}

- (void)bindShortcutForKey:(ushort)aKeyCode keyText:(NSString*)aKeyText Flags:(NSEventModifierFlags)flags {
    if (self->keyCode == aKeyCode && self->modifierFlags == flags)
        return;

    self->keyCode = aKeyCode;
    self->keyText = [[self class] extractKeyTextFromKeyCode:aKeyCode optionalCharacters:aKeyText];
    self->modifierFlags = flags;
    self->bound = YES;
    
    [super setNeedsDisplay:YES];
    
    NSString* pk = self.persistanceKey;
    if (pk) {
        NSArray* value = @[
                           [NSNumber numberWithUnsignedShort:aKeyCode],
                           self->keyText,
                           [NSNumber numberWithUnsignedInteger:flags] ];
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:value forKey:pk];
    }
}

- (void)unbindShortcut {
    [self clearShortcut];
    [super setNeedsDisplay:YES];
    
    NSString* pk = self.persistanceKey;
    if (pk) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:pk];
    }
}

- (void)beginKeyByKeyModeWithKey:(ushort)aKeyCode keyText:(NSString*)aKeyText {
    self->keyByKey = YES;
    self->keyCode = aKeyCode;
    self->keyText = [[self class] extractKeyTextFromKeyCode:aKeyCode optionalCharacters:aKeyText];
    [super setNeedsDisplay:YES];
}

- (void)endKeyByKeyCode {
    self->keyByKey = NO;
    ushort tmpKeyCode = self->keyCode;
    RT_ASSERT(tmpKeyCode != 0);
    self->keyCode = 0;
    [self bindShortcutForKey:tmpKeyCode keyText:self->keyText Flags:self->modifierFlags];
}

- (void)clearShortcut {
    self->keyCode = 0;
    self->keyText = @"";
    self->modifierFlags = 0;
    self->clearable = NO;
    self->bound = NO;
    self->keyByKey = NO;
}

+ (NSString*)extractKeyTextFromKeyCode:(ushort)keyCode optionalCharacters:(NSString*)characters {
    NSString* output = @"";
    if ([characters hasContent]) {
        output = characters.uppercaseString;
    }
    else {
        output = [KeyCodeUtils textFromKeyCode:keyCode];
    }
    NSString* specialKeyCodeText = [KeyCodeUtils textFromSpecialKeyCode:keyCode];
    if (specialKeyCodeText) {
        output = specialKeyCodeText;
    }
    return output;
}

- (NSDictionary *)shortcutTextAttributes {
    static dispatch_once_t token;
    static NSDictionary *attributes = nil;
    dispatch_once(&token, ^{
        NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
        p.alignment = NSCenterTextAlignment;
        p.lineBreakMode = NSLineBreakByTruncatingTail;
        p.baseWritingDirection = NSWritingDirectionLeftToRight;
        attributes = @{
                     NSParagraphStyleAttributeName: [p copy],
                     NSFontAttributeName: [NSFont labelFontOfSize:[NSFont systemFontSize]],
                     NSForegroundColorAttributeName: [NSColor controlTextColor]
                     };
    });
    return attributes;
}

- (NSDictionary *)clearButtonAttributes {
    static dispatch_once_t token;
    static NSDictionary *attributes = nil;
    dispatch_once(&token, ^{
        NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
        p.alignment = NSCenterTextAlignment;
        p.lineBreakMode = NSLineBreakByTruncatingTail;
        p.baseWritingDirection = NSWritingDirectionLeftToRight;
        attributes = @{
                     NSParagraphStyleAttributeName: [p copy],
                     NSFontAttributeName: [NSFont labelFontOfSize:[NSFont smallSystemFontSize]],
//                     NSFontAttributeName: [NSFont fontWithName:@"FontAwesome" size:10],
                     NSForegroundColorAttributeName: [NSColor controlTextColor]
                     };
    });
    return attributes;
}

- (NSRect)clearButtonRect {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        const CGFloat clearButtonSizeRatio = 0.65;
        const CGFloat clearButtonSize = self.bounds.size.height * clearButtonSizeRatio;
        _clearButtonRect= NSMakeRect(self.bounds.size.width - clearButtonSize*1.4,
                          self.bounds.size.height * (1 - clearButtonSizeRatio)*0.5,
                          clearButtonSize,
                          clearButtonSize);
        _clearButtonRect = [self centerScanRect:_clearButtonRect];
    });
    return _clearButtonRect;
}

- (void)drawClearButton {
    NSRect rect = self.clearButtonRect;
    
    if ([self needsToDrawRect:rect] && self->clearable) {
        [NSGraphicsContext saveGraphicsState];
        
        [[NSColor colorWithWhite:0.8 alpha:0.8] set];
        CGFloat radius = rect.size.width * 0.5;
        [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius] fill];
        
        NSDictionary* clearButtonAttributes = [self clearButtonAttributes];
        CGFloat fontBaselineOffset = [clearButtonAttributes[NSFontAttributeName] descender];
        rect = NSInsetRect(rect, 2.0, 2.0);
        rect.origin.y -= fontBaselineOffset;
        rect = [self centerScanRect:rect];
        [@"\u2718" drawInRect:rect withAttributes:clearButtonAttributes];
        
        [NSGraphicsContext restoreGraphicsState];
    }
}

#pragma mark NSView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self->active) {
        if (self->keyByKey)
            [[NSColor cyanColor] set];
        else
            [[NSColor whiteColor] set];
        NSRectFill(self.bounds);
    }
    
    if (self->bound || self->keyByKey) {
        [self drawClearButton];
        
        NSString* shortcutText = self.stringValue;
        
        NSDictionary* shortcutTextAttributes = [self shortcutTextAttributes];
        NSSize shortcutRectSize = [shortcutText sizeWithAttributes:shortcutTextAttributes];
        CGFloat fontBaselineOffset = [shortcutTextAttributes[NSFontAttributeName] descender];
        NSRect shortcutRect = NSMakeRect(NSMidX(self.bounds) - shortcutRectSize.width * .5,
                                         -fontBaselineOffset,
                                        shortcutRectSize.width*1.2,
                                         shortcutRectSize.height);
        
        if (self.clearButtonRect.origin.x < shortcutRect.origin.x + shortcutRect.size.width) {
            // Avoid overlaps between the shortcut area and clear button area.
            shortcutRect.origin.x = self.clearButtonRect.origin.x - shortcutRect.size.width;
        }
        
        shortcutRect = [self centerScanRect:shortcutRect];
        if ([self needsToDrawRect:shortcutRect]) {
            [NSGraphicsContext saveGraphicsState];
            [shortcutText drawInRect:shortcutRect withAttributes:shortcutTextAttributes];
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    
    [[NSColor lightGrayColor] set];
    NSFrameRectWithWidth(self.bounds, 1.0);
    
    if (self->active) {
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill(self.bounds);
    }
}


#pragma mark NSResponder

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    self->active = YES;
    [super setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self->active = NO;
    self->clearable = NO;
    [super setNeedsDisplay:YES];
    return [super resignFirstResponder];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (BOOL)canBecomeKeyView {
    return [super canBecomeKeyView] && [NSApp isFullKeyboardAccessEnabled];
}

- (BOOL)needsPanelToBecomeKey {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self->active && self->clearable) {
        NSPoint ptInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
        if ([self mouse:ptInView inRect:self.clearButtonRect]) {
            [self unbindShortcut];
        }
    }
    
    self->clearable = YES;
    
    [super mouseDown:theEvent];
}

//- (void)mouseUp:(NSEvent *)theEvent {
//    [super mouseUp:theEvent];
//}
//
//- (void)mouseEntered:(NSEvent *)theEvent {
//    [super mouseEntered:theEvent];
//}
//
//- (void)mouseExited:(NSEvent *)theEvent {
//    [super mouseExited:theEvent];
//}

- (void)keyDown:(NSEvent *)theEvent {
    if (!self->active) {
        [super keyDown:theEvent];
        return;
    }
    
    NSUInteger maskedModifierFlags = theEvent.modifierFlags & defaultModifierKeyMask;
    
    if (maskedModifierFlags == 0) {
        // Ignore any key with no modifier.
        return;
    }
    if ((maskedModifierFlags ^ NSShiftKeyMask) == 0) {
        // Skip when shift key alone being pressed.
        return;
    }
    
    [self bindShortcutForKey:theEvent.keyCode keyText:theEvent.charactersIgnoringModifiers Flags:theEvent.modifierFlags];
    
//    if (theEvent.keyCode == kVK_Escape) {
//        [self.window makeFirstResponder:nil];
//    }
    
    [super setNeedsDisplay:YES];
}

- (void)keyUp:(NSEvent *)theEvent {
    if (!self->active) {
        [super keyUp:theEvent];
        return;
    }
    
    NSUInteger maskedModifierFlags = theEvent.modifierFlags & defaultModifierKeyMask;
    
    if (maskedModifierFlags == 0) {
        if (self->keyByKey) {
            if (theEvent.keyCode == kVK_Return) {
                [self endKeyByKeyCode];
            }
            else if (theEvent.keyCode == kVK_Escape) {
                [self unbindShortcut];
            }
        }
        else if (self->modifierFlags == 0) {
            [self beginKeyByKeyModeWithKey:theEvent.keyCode keyText:theEvent.charactersIgnoringModifiers];
        }
    }
}

- (void)flagsChanged:(NSEvent *)theEvent {
    if (!self->active || !self->keyByKey) {
        [super flagsChanged:theEvent];
        return;
    }
    
    NSEventModifierFlags flags = theEvent.modifierFlags;
    if (flags & NSCommandKeyMask) {
        self->modifierFlags |= NSCommandKeyMask;
    }
    else if (flags & NSAlternateKeyMask) {
        self->modifierFlags |= NSAlternateKeyMask;
    }
    else if (flags & NSControlKeyMask) {
        self->modifierFlags |= NSControlKeyMask;
    }
    else if (flags & NSShiftKeyMask) {
        self->modifierFlags |= NSShiftKeyMask;
    }
    else {
        [super setNeedsDisplay:YES];
    }
}

@end
