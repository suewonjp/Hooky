//
//  MacroTools.h
//  Hooky
//
//  Created by Suewon Bahng on 3/14/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#ifndef MACROTOOLS_H
#define MACROTOOLS_H

//
// Detecting the target system.
// Modified the original code found at http://nadeausoftware.com/articles/2012/01/c_c_tip_how_use_compiler_predefined_macros_detect_operating_system
//
#if defined(__APPLE__) && defined(__MACH__)
/* Apple OSX and iOS (Darwin). ------------------------------ */
#include <TargetConditionals.h>

// Note that the check order is significant. Do not change.
#if TARGET_IPHONE_SIMULATOR == 1
    /* iOS in Xcode simulator */
    #define IOS (1)
    #define IOS_SIMULATOR (1)
    #define IOS_DEVICE (0)
    #define OSX (0)
#elif TARGET_OS_IPHONE == 1
    /* iOS on iPhone, iPad, etc. */
    #define IOS (1)
    #define IOS_SIMULATOR (0)
    #define IOS_DEVICE (1)
    #define OSX (0)
#elif TARGET_OS_MAC == 1
    /* OSX */
    #define IOS (0)
    #define IOS_SIMULATOR (0)
    #define IOS_DEVICE (0)
    #define OSX (1)
#endif

#endif

//
// Macro Stringification. More Comprehensible than using #
//
#define _QUOTATION_(x) #x
#define QUOTATION(x) _QUOTATION_(x)

//
// Macro Concatenation. More comprehensible than using ##
//
#define _CONCATENATION_(a, b) a##b
#define CONCATENATION(a, b) _CONCATENATION_(a, b)

//
// Name Generator for temporary variables, etc.
// Guaranteed *Unique* unless used more than once at the same line.
//
#define TRANSIENT_NAME(name) CONCATENATION(name, __LINE__)

//
// Run Time Assert
//
#if defined(DEBUG)
    #define RT_ASSERT(condition) { NSAssert(condition, @"Assert Violation!!!"); }
#else
    #define RT_ASSERT(condition) {}
#endif

//
// Compile Time Assert
//
#define CT_ASSERT(expr) typedef char TRANSIENT_NAME(__ct_assert__) [(expr) ? 1 : -1];

//
// Type Check Assert For Objective C Objects
//
#define TYPE_ASSERT(type, instance) RT_ASSERT([(instance) isKindOfClass:[type class]])

//
// No Operation.
// Useful as a breakpoint acceptable placeholder when you can't put a breakpoint on some edge spots in your code
//
#define NOOP RT_ASSERT(1)

//
// Return the number of members of a static array
//
#define COUNT_ARRAY_MEMBERS(A) (sizeof(A) / sizeof(*(A)))

//
// Swap variables
//
#define SWAP(a, b) { \
        const typeof(a) __swap__temp__ = a; \
        a = b; \
        b = __swap__temp__; \
    }

//
// Return maximum value of the two
//
#define MAX2(a, b) \
    ({ typeof(a) _a = (a); typeof(b) _b = (b); _a < _b ? _b : _a; })

//
// Return minimum value of the two
//
#define MIN2(a, b) \
    ({ typeof(a) _a = (a); typeof(b) _b = (b); _a < _b ? _a : _b; })

//
// Return maximum value of the tree
//
#define MAX3(a, b, c) MAX2(MAX2(a, b), c)
    //((a) < (b) ? (((b) < (c) ? (c) : (b))) : (((a) < (c) ? (c) : (a))))

//
// Return minimum value of the tree
//
#define MIN3(a, b, c) MIN2(MIN2(a, b), c)
    //((a) < (b) ? (((a) < (c) ? (a) : (c))) : (((b) < (c) ? (b) : (c))))

//
// Clip a value between a range
//
#define CLIP(v, minv, maxv) MIN2(MAX2(minv, v), maxv)

#if defined(__OBJC__)

//
// Run arbitrary code only once.
//
#define RUN_ONCE_BEGIN { static dispatch_once_t TRANSIENT_NAME(__only__once__); dispatch_once(&TRANSIENT_NAME(__only__once__), ^{

#define RUN_ONCE_END });}

#endif


#endif /* MACROTOOLS_H */
