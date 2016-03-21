//
//  PersistenceManager.h
//  Hooky
//
//  Created by Suewon Bahng on 3/10/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PersistenceManagerDelegate <NSObject>

@optional
- (NSString*)enclosingPath;
- (void)preload:(NSString*) storagePath;
- (void)presave:(NSString*) storagePath;
- (void)postsave:(NSString*) storagePath;

@end

@interface PersistenceManager : NSObject

@property (nonatomic) id<PersistenceManagerDelegate> delegate;

- (id)load;

- (BOOL)save:(id)data;

@end
