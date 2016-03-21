//
//  ShortcutView.h
//  CaseByCaseObjC
//
//  Created by Suewon Bahng on 3/1/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShortcutView : NSView

@property (nonatomic, readwrite) NSString* stringValue;
@property (nonatomic, readwrite) NSString* persistanceKey;

@end
