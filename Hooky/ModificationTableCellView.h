//
//  ModificationTableCellView.h
//  Hooky
//
//  Created by Suewon Bahng on 3/5/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TableRowModificationDelegate <NSObject>

@optional
- (void)editRow:(NSInteger)row;
- (void)deleteRow:(NSInteger)row;
- (void)setRow:(NSInteger)row enabled:(BOOL)enable;

@end

@interface ModificationTableCellView : NSTableCellView

@property (weak) IBOutlet NSButton* active;
@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) id<TableRowModificationDelegate> delegate;

- (IBAction)onEditBtn:(NSButton*)sender;
- (IBAction)onDeleteBtn:(NSButton*)sender;
- (IBAction)onEnableBtn:(NSButton*)sender;

@end

