//
//  ModificationTableCellView.m
//  Hooky
//
//  Created by Suewon Bahng on 3/5/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "ModificationTableCellView.h"
#import "Utils.h"

@interface  ModificationTableCellView () {
}

@end

@implementation ModificationTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (IBAction)onEditBtn:(NSButton*)sender {
    if ([self.delegate respondsToSelector:@selector(editRow:)]) {
        [self.delegate editRow:self.rowIndex];
    }
}

- (IBAction)onDeleteBtn:(NSButton*)sender {
    if ([self.delegate respondsToSelector:@selector(deleteRow:)]) {
        [self.delegate deleteRow:self.rowIndex];
    }
}

- (IBAction)onEnableBtn:(NSButton*)sender {
    BOOL enable = (sender.state == NSOnState);
    if ([self.delegate respondsToSelector:@selector(setRow:enabled:)]) {
        [self.delegate setRow:self.rowIndex enabled:enable];
    }
}

@end
