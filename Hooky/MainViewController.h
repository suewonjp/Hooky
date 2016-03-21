//
//  MainViewController.h
//  Hooky
//
//  Created by Suewon Bahng on 3/4/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EventHookManager;
@class PersistenceManager;

@interface MainViewController : NSViewController

@property (assign, nonatomic) EventHookManager* evtHkMgr;
@property (assign, nonatomic) PersistenceManager* pstMgr;

- (BOOL)loadSettings;

@end
