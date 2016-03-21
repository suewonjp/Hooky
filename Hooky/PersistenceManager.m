//
//  PersistenceManager.m
//  Hooky
//
//  Created by Suewon Bahng on 3/10/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "PersistenceManager.h"
#import "Utils.h"

@interface PersistenceManager () {
    __weak NSFileManager* fm;
}

@property (strong, nonatomic) NSString* storagePath;

@end

@implementation PersistenceManager

- (instancetype)init {
    self = [super init];
    self->fm = [NSFileManager defaultManager];
    return self;
}

- (NSString*)privateHomePath {
    NSString* enclosingPath = NSHomeDirectory();
    if (_delegate && [_delegate respondsToSelector:@selector(enclosingPath)]) {
        enclosingPath = [_delegate enclosingPath];
    }
    return [NSString stringWithFormat:@"%@/.hooky", enclosingPath];
}

- (NSString*)storagePath {
    if (_storagePath) {
        return _storagePath;
    }
    _storagePath = [NSString stringWithFormat:@"%@/settings.json", [self privateHomePath]];
    return _storagePath;
}

- (BOOL)createPrivateHomeDirectory {
    NSString* appPrivateHomePath = [self privateHomePath];
    NSError* err = nil;
    if ([self->fm fileExistsAtPath:appPrivateHomePath]) {
        return YES;
    }
    if (![fm createDirectoryAtPath:appPrivateHomePath withIntermediateDirectories:YES attributes:nil error:&err]) {
        if (err) {
            [Utils alert:err.localizedDescription withInfo:err.localizedFailureReason withIcon:nil];
        }
        return NO;
    }
    return YES;
}

- (id)load {
    NSString* srcPath = self.storagePath;
    if (_delegate && [_delegate respondsToSelector:@selector(presave:)]) {
        [_delegate presave:srcPath];
    }
    
    NSData* serializedData = [NSData dataWithContentsOfFile:srcPath];
    if (!serializedData) {
        return nil;
    }
    
    NSError* err = nil;
    id output = [NSJSONSerialization JSONObjectWithData:serializedData
                                    options:0
                                      error:&err];
    if (!output) {
        if (err) {
            [Utils alert:err.localizedDescription withInfo:err.localizedFailureReason withIcon:nil];
        }
        return nil;
    }
    
    return output;
}

- (BOOL)save:(id)data {
    NSError* err = nil;
    NSData* serializedData =
        [NSJSONSerialization dataWithJSONObject:data
                                        options:0 error:&err];
    if (!serializedData) {
        if (err) {
            [Utils alert:err.localizedDescription withInfo:err.localizedFailureReason withIcon:nil];
        }
        return NO;
    }
    
    if (![self createPrivateHomeDirectory]) {
        return NO;
    }
    
    NSString* srcPath = self.storagePath;
    
    if (_delegate && [_delegate respondsToSelector:@selector(presave:)]) {
        [_delegate presave:srcPath];
    }
    
    if (![serializedData writeToFile:srcPath atomically:NO]) {
        return NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(postsave:)]) {
        [_delegate postsave:srcPath];
    }
    
    return  YES;
}

@end
