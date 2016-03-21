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
    #define RT_ASSERT(condition) NSAssert(condition, @"Assert Violation!!!")
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
#if defined(DEBUG)
    #define TYPE_ASSERT(type, instance) NSAssert([(instance) isKindOfClass:[type class]], @"Class Type Mismatch!!!")
#else
    #define TYPE_ASSERT(type, instance) {}
#endif

//
// No Operation.
// Useful as a breakpoint acceptable placeholder when you can't put a breakpoint on some edge spots in your code
//
#define NOOP RT_ASSERT(TRUE)

//
// Return the number of members of a static array
//
#define COUNT_ARRAY_MEMBERS(A) (sizeof(A) / sizeof(*(A)))

//
// Swap variables
//
#define SWAP(A, B, VARIABLE_TYPE) { \
        const VARIABLE_TYPE __swap__temp__ = A; \
        A = B; \
        B = __swap__temp__; \
    }


#define MAX2(A, B) ((A) < (B) ? (B) : (A))
#define MAX3(A, B, C) ((A) < (B) ? (((B) < (C) ? (C) : (B))) : (((A) < (C) ? (C) : (A))))

#define MIN2(A, B) ((A) < (B) ? (A) : (B))
#define MIN3(A, B, C) ((A) < (B) ? (((A) < (C) ? (A) : (C))) : (((B) < (C) ? (B) : (C))))

#if defined(__OBJC__)

//
// Run arbitrary code only once.
//
#define RUN_ONCE_BEGIN { static dispatch_once_t TRANSIENT_NAME(__only__once__); dispatch_once(&TRANSIENT_NAME(__only__once__), ^{

#define RUN_ONCE_END });}

#endif


#endif /* MACROTOOLS_H */
