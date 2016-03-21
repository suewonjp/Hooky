//
//  AppDelegate.m
//  Hooky
//
//  Created by Suewon Bahng on 3/4/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "EventHookManager.h"
#import "PersistenceManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow*     window;
@property (strong) NSStatusItem*        statusItem;
@property (strong) NSPopover*           popover;
@property (strong) EventHookManager*    evtHkMgr;
@property (strong) PersistenceManager*  pstMgr;

@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    self.popover = [[NSPopover alloc] init];
    
    AppDelegate* __weak appDelegate = self;
    self.evtHkMgr = [EventHookManager eventHookWithDefaultHandler:^(NSEvent* event) {
                                       [appDelegate closePopover:nil];
                                   }];
    
    self.pstMgr = [[PersistenceManager alloc] init];
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSButton* button = self.statusItem.button;
    if (button) {
        button.image = [NSImage imageNamed:@"NSActionTemplate"];
        button.action = @selector(togglePopover:);
    }
    
    MainViewController* viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    viewController.evtHkMgr = self.evtHkMgr;
    viewController.pstMgr = self.pstMgr;
    [viewController loadSettings];
    
    self.popover.contentViewController = viewController;
    
    [self.evtHkMgr start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.evtHkMgr stop];
}

- (void)showPopover:(id)sender {
    NSButton* button = self.statusItem.button;
    if (button) {
        [self.popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMinY];
    }
}

- (void)closePopover:(id)sender {
    [self.popover performClose:sender];
}

- (void)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self closePopover:sender];
    }
    else {
        [self showPopover:sender];
    }
}

@end
