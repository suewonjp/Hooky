//
//  TableRowContent.h
//  Hooky
//
//  Created by Suewon Bahng on 3/13/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct EventHookItem;

@interface TableRowContent : NSObject

@property (strong, nonatomic) NSString* proxyEventType;
@property (strong, nonatomic) NSString* targetShortcut;
@property (nonatomic)         BOOL      active;

+ (NSUInteger)countMouseButtonNames;

+ (NSString*)mouseButtonNameAt:(NSUInteger)index;

+ (NSUInteger)countKeyPressTypeNames;

+ (NSString*)keyPressTypeNameAt:(NSUInteger)index;

- (instancetype)initWithEventHookItem:(const struct EventHookItem*)item;

- (void)proxyEventTypeWithMouseButtonIndex:(NSInteger)mbIndex clickTypeIndex:(NSInteger)ctIndex flags:(NSEventModifierFlags)flags;

@end
