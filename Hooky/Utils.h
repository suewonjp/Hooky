//
//  Util.h
//  HelloWorld
//
//  Created by Suewon Bahng on 5/27/14.
//  Copyright (c) 2014 bsw_corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroTools.h"

@interface Utils : NSObject

+ (void)alert:(NSString*)msg
     withInfo:(NSString*)info
     withIcon:(NSString*)unicodeIcon;

+ (BOOL)ask:(NSString*)question
   withInfo:(NSString*)info;

@end

@interface NSString (hasContent)

- (BOOL)hasContent;

@end
