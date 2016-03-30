//
//  MainViewController.m
//  Hooky
//
//  Created by Suewon Bahng on 3/4/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import "MainViewController.h"
#import "ShortcutView.h"
#import "KeyCodeUtils.h"
#import "ModificationTableCellView.h"
#import "EventHookManager.h"
#import "PersistenceManager.h"
#import "Utils.h"
#import "TableRowContent.h"
#import "ViewPingPongAnimator.h"

@interface MainViewController () <TableRowModificationDelegate> {
    __weak IBOutlet NSTableView *hookTableView;
    
    __weak IBOutlet NSTextField *msgLabel;
    
    __weak IBOutlet NSButton *addButton;
    __weak IBOutlet NSButton *registerButton;
    __weak IBOutlet NSButton *pauseButton;
    __weak IBOutlet NSButton *quitButton;
        
    __weak IBOutlet NSBox *editBox;
    
    __weak IBOutlet NSPopUpButton *proxyEventMouseBtn;    
    __weak IBOutlet NSPopUpButton *proxyEventPressType;
    __weak IBOutlet NSButton *proxyEventModKeyCmd;
    __weak IBOutlet NSButton *proxyEventModKeyOpt;
    __weak IBOutlet NSButton *proxyEventModKeyCtl;
    __weak IBOutlet NSButton *proxyEventModKeySft;
    __weak IBOutlet ShortcutView *targetShortcut;
    
    NSButton*__weak* proxyEventModKeyBtns[EndOfModifierKeyType];
    
    NSInteger rowBeingEdited;
    
    ViewPingPongAnimator* editBoxAnimator;
    
    BOOL mkmMode;
}

@property (strong, nonatomic) NSMutableArray* tableRowContents;

- (IBAction)onNewHook:(NSButton *)sender;

- (IBAction)onRegisterHook:(NSButton *)sender;

- (IBAction)onHideEditBox:(NSButton *)sender;

- (IBAction)onPause:(NSButton *)sender;

- (IBAction)onQuit:(NSButton *)sender;

- (IBAction)onProxyEventMouseBtn:(NSPopUpButton *)sender;

- (IBAction)onProxyEventModKeys:(NSButton *)sender;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString*)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self->proxyEventModKeyBtns[ModifierKeyTypeCommand] = &self->proxyEventModKeyCmd;
    self->proxyEventModKeyBtns[ModifierKeyTypeOption] = &self->proxyEventModKeyOpt;
    self->proxyEventModKeyBtns[ModifierKeyTypeControl] = &self->proxyEventModKeyCtl;
    self->proxyEventModKeyBtns[ModifierKeyTypeShift] = &self->proxyEventModKeySft;
    
    self->rowBeingEdited = -1;
    self->mkmMode = NO;
    
    self.tableRowContents = [NSMutableArray array];
    
    return self;
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateMouseButtonMenu];
    [self populatePressTypeMenu];
        
    CGFloat standByPos = -self.view.frame.size.width - 100.0f;
    self->editBoxAnimator = [ViewPingPongAnimator animatorWithView:self->editBox containingView:self.view
    initialStateHandler:^(NSView *view, NSView *containingView) {
        CGRect frame = view.frame;
        frame.origin.x = standByPos;
        view.frame = frame;
    } pingStateHandler:^(NSView *view, NSView *containingView) {
        CGRect frame = view.frame;
        frame.origin.x = 20.0f;
        [[view animator] setFrame:frame];
    } pongStateHandler:^(NSView *view, NSView *containingView) {
        CGRect frame = view.frame;
        frame.origin.x = standByPos;
        [[view animator] setFrame:frame];
    }];
    
    self->addButton.toolTip = @"Add New Hook";
    self->registerButton.toolTip = @"Register Hook";
    self->quitButton.toolTip = @"Quit App";
    
    [self toggleAllHooksActivation:YES];
    
#ifdef DEBUG
    [self printMessage:@"Debug Build"];
#endif
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self->editBoxAnimator reset];
    self->addButton.enabled = YES;
    self->registerButton.enabled = NO;
}

//- (void)viewWillDisappear {
//    [super viewWillDisappear];
//}

#pragma mark Private Helpers

- (void)printMessage:(NSString*)msg {
    if (self->msgLabel.enabled) {
        self->msgLabel.stringValue = msg ? msg : @"";
    }
}

#pragma mark Edit Box Manipulation

- (void)populateMouseButtonMenu {
    NSUInteger c = [TableRowContent countMouseButtonNames];
    for (int i=0; i<c; ++i) {
        [self->proxyEventMouseBtn addItemWithTitle:[TableRowContent mouseButtonNameAt:i]];
    }
}

- (void)resetMouseButtonMenu {
    [self->proxyEventMouseBtn selectItemAtIndex:MouseButtonTypeMiddle];
}

- (void)selectMouseButtonMenuByText:(NSString*)proxyEventText {
    NSUInteger c = [TableRowContent countMouseButtonNames];
    self->proxyEventMouseBtn.autoenablesItems = NO;
    for (int i=0; i<c; ++i) {
        if ([proxyEventText containsString:[TableRowContent mouseButtonNameAt:i]]) {
            [self->proxyEventMouseBtn selectItemAtIndex:i];
            break;
        }
    }
//    [self->proxyEventMouseBtn.menu itemAtIndex:MouseButtonTypeNone].enabled = NO;
}

- (void)populatePressTypeMenu {
    NSUInteger c = [TableRowContent countKeyPressTypeNames];
    self->proxyEventPressType.autoenablesItems = NO;
    for (int i=0; i<c; ++i) {
        [self->proxyEventPressType addItemWithTitle:[TableRowContent keyPressTypeNameAt:i]];
    }
    [self->proxyEventPressType.menu itemAtIndex:PressTypeNone].enabled = NO;
}

- (void)resetPressTypeMenu {
    if (self->mkmMode) {
        [self->proxyEventPressType.menu itemAtIndex:PressTypeSingle].enabled = NO;
        [self->proxyEventPressType.menu itemAtIndex:PressTypeQuadruple].enabled = YES;
        [self->proxyEventPressType.menu itemAtIndex:PressTypeLong].enabled = NO;
        [self->proxyEventPressType selectItemAtIndex:PressTypeDouble];
    }
    else {
        [self->proxyEventPressType.menu itemAtIndex:PressTypeSingle].enabled = YES;
        [self->proxyEventPressType.menu itemAtIndex:PressTypeQuadruple].enabled = NO;
        [self->proxyEventPressType.menu itemAtIndex:PressTypeLong].enabled = YES;
        [self->proxyEventPressType selectItemAtIndex:PressTypeSingle];
    }
}

- (void)selectPressTypeMenuByText:(NSString*)proxyEventText {
    int c = (int)[TableRowContent countKeyPressTypeNames];
    for (int i=c-1; i>-1; --i) {
        if ([proxyEventText containsString:[TableRowContent keyPressTypeNameAt:i]]) {
            [self->proxyEventPressType selectItemAtIndex:i];
            break;
        }
    }
}

- (void)populateEditBoxWithTableRow:(NSInteger)row {
    TableRowContent* rowContent  =self.tableRowContents[row];
    NSString* proxyEventText = rowContent.proxyEventType;

    [self selectMouseButtonMenuByText:proxyEventText];
    [self selectPressTypeMenuByText:proxyEventText];
    
    [self clearModifierCheckBoxes];
    if ([proxyEventText containsString:@"⌘"])
        self->proxyEventModKeyCmd.state = NSOnState;
    if ([proxyEventText containsString:@"⌥"])
        self->proxyEventModKeyOpt.state = NSOnState;
    if ([proxyEventText containsString:@"⌃"])
        self->proxyEventModKeyCtl.state = NSOnState;
    if ([proxyEventText containsString:@"⇧"])
        self->proxyEventModKeySft.state = NSOnState;
    
    self->targetShortcut.stringValue = rowContent.targetShortcut;
}

- (void)initEditBoxWithTableRow:(NSInteger)row {
    if (row > -1) {
        // Initialize with an existing hook
        [self populateEditBoxWithTableRow:row];
    }
    else {
        // Initialize for a new hook
        [self resetMouseButtonMenu];
        self->mkmMode = NO;
        [self resetPressTypeMenu];
        [self clearModifierCheckBoxes];
        self->targetShortcut.stringValue = nil;
    }
}

- (void)activateEditModeWithRow:(NSInteger)row {
    [self initEditBoxWithTableRow:row];
    self->rowBeingEdited = row;
    self->addButton.enabled = NO;
    self->registerButton.enabled = YES;
    [self->editBoxAnimator ping];
}

- (void)deactivateEditMode {
    self->rowBeingEdited = -1;
    self->addButton.enabled = YES;
    self->registerButton.enabled = NO;
    [self->editBoxAnimator pong];
}

- (void)clearModifierCheckBoxes {
    for (int i=0; i<EndOfModifierKeyType; ++i)
        (*self->proxyEventModKeyBtns[i]).state = NSOffState;
}

- (NSEventModifierFlags)proxyEventModifierFlags {
    NSEventModifierFlags flags = 0;
    if (self->proxyEventModKeyCmd.state == NSOnState)
        flags |= NSCommandKeyMask;
    if (self->proxyEventModKeyOpt.state == NSOnState)
        flags |= NSAlternateKeyMask;
    if (self->proxyEventModKeyCtl.state == NSOnState)
        flags |= NSControlKeyMask;
    if (self->proxyEventModKeySft.state == NSOnState)
        flags |= NSShiftKeyMask;
    return flags;
}

#pragma mark Model Manipulation

- (NSString*)targetShortcutTextFromKeyCode:(CGKeyCode)code flags:(NSEventModifierFlags)flags {
    NSString* keyText = [KeyCodeUtils textFromKeyCode:code];
    NSString* modText  =[KeyCodeUtils textFromModifierFlags:flags];
    return [NSString stringWithFormat:@"%@ %@", modText, keyText];
}

- (BOOL)updateHookAtTableRow:(NSInteger)row {
    NSString* shortcutText = self->targetShortcut.stringValue;
    if (![shortcutText hasContent]) {
        // Users need to fill in the target shortcut
        [Utils alert:@"Data Incomplete!" withInfo:@"No shortcut specified!" withIcon:nil];
        return NO;
    }
    
    // Populate the content of the table row
    TableRowContent* rowContent = [[TableRowContent alloc] init];
    rowContent.targetShortcut = shortcutText;
    [rowContent proxyEventTypeWithMouseButtonIndex:self->proxyEventMouseBtn.indexOfSelectedItem clickTypeIndex:self->proxyEventPressType.indexOfSelectedItem flags:[self proxyEventModifierFlags]];
    
    if (row == -1) {
        // A new hook item comes in.
        // We need to check duplicate items
        NSArray* prxEvtTypes = [self.tableRowContents valueForKey:@"proxyEventType"];
        if ([prxEvtTypes containsObject:rowContent.proxyEventType]) {
            [Utils alert:@"You've already mapped the Proxy Event!" withInfo:rowContent.proxyEventType withIcon:nil];
            return  NO;
        }
        else {
            [self.tableRowContents addObject:rowContent];
        }
    }
    else {
        self.tableRowContents[row] = rowContent;
    }
    
    [self->hookTableView reloadData]; // Update the table view
    
    [self deactivateEditMode];
    
    // Register this hook into the EventHook object
    CGKeyCode shortcutPlainKeyCode = 0;
    NSEventModifierFlags shortcutModifierFlags = 0;
    [KeyCodeUtils getKeyCode:&shortcutPlainKeyCode keyText:nil flags:&shortcutModifierFlags flagsText:nil fromText:shortcutText];
    const EventHookItem hookItem = {
        {
            (int8_t)self->proxyEventMouseBtn.indexOfSelectedItem,
            (int8_t)self->proxyEventPressType.indexOfSelectedItem,
            0,
            [self proxyEventModifierFlags],
        },
        shortcutModifierFlags,
        shortcutPlainKeyCode,
        true,
    };
    [self.evtHkMgr.hookStore setHook:&hookItem at:row];
    
    // We persist settings whenever users change them.
    [self saveSettings];
    
    return YES;
}

- (void)deleteHookAtTableRow:(NSInteger)row {
    if ([Utils ask:@"Are you sure you want to delete it?" withInfo:[self.tableRowContents[row] valueForKey:@"proxyEventType"]] == NO) {
        return;
    }

    [self.tableRowContents removeObjectAtIndex:row];
    [self->hookTableView reloadData];
    
    // Delete the hook from the EventHook object.
    [self.evtHkMgr.hookStore removeHookAt:row];
    
    [self saveSettings];
}

- (void)turnHookAtTableRow:(NSInteger)row asActive:(BOOL)active {
    [(TableRowContent*)self.tableRowContents[row] setActive:active];
    [self->hookTableView reloadData];
    
    // Activate or deactive the hook.
    [self.evtHkMgr.hookStore turnHookAt:row asActive:active];
    
    [self saveSettings];
}

- (void)toggleAllHooksActivation:(BOOL)forceReset {
    BOOL willPause = NO;
    if (self.evtHkMgr && forceReset == NO) {
        willPause = [self.evtHkMgr active];
        [self.evtHkMgr activate:!willPause];
    }
    if (willPause) {
        //        self->pauseButton.title = @"\xf0\x9f\x94\x84";
        self->pauseButton.title = @"\U0001f504";
        self->pauseButton.toolTip = @"Reactivate All Hooks";
    }
    else {
        self->pauseButton.title = @"\u23f8";
        self->pauseButton.toolTip = @"Pause All Hooks";
    }
}

#pragma mark Data Persistence

- (void)saveSettings {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [self.evtHkMgr.hookStore toDictionary:dict];
    [self.pstMgr save:dict];
}

- (BOOL)loadSettings {
    id data = [self.pstMgr load];
    if (!data)
        return NO;
    
    TYPE_ASSERT(NSDictionary, data);
    [self.evtHkMgr.hookStore fromDictionary:(NSDictionary*)data];
    
    const NSUInteger c = [self.evtHkMgr.hookStore countHooks];
    for (NSUInteger i=0; i<c; ++i) {
        const EventHookItem* item = [self.evtHkMgr.hookStore hookAt:i];
        TableRowContent* rowContent = [[TableRowContent alloc] initWithEventHookItem:item];
        [self.tableRowContents addObject:rowContent];
    }
    
    [self->hookTableView reloadData];
    return  YES;
}

#pragma mark TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.tableRowContents.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString* identifier = [tableColumn identifier];
    TableRowContent* rowContent = self.tableRowContents[row];
    NSTableCellView* cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    
    if ([identifier isEqualToString:@"editUIs"]) {
        TYPE_ASSERT(ModificationTableCellView, cellView);
        ModificationTableCellView* subCellView = (ModificationTableCellView*)cellView;
        subCellView.rowIndex = row;
        subCellView.active.state = rowContent.active ? NSOnState : NSOffState;
        subCellView.delegate = self;
        return subCellView;
    }
    
    NSString* text = [rowContent valueForKey:identifier];
    cellView.textField.stringValue = text;
    cellView.textField.drawsBackground = YES;
    NSArray* bgColors = [NSColor controlAlternatingRowBackgroundColors];
    cellView.textField.backgroundColor = bgColors[row % 2];
    BOOL active = [(TableRowContent*)self.tableRowContents[row] active] && [self.evtHkMgr active];
    cellView.textField.textColor = active ? [NSColor textColor] : [NSColor tertiaryLabelColor];
    return cellView;
}

- (void)tableView:(NSTableView *)tableView
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
    NSArray* bgColors = [NSColor controlAlternatingRowBackgroundColors];
    rowView.backgroundColor = bgColors[row % 2];
    rowView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}

#pragma mark Actions

- (IBAction)onNewHook:(NSButton *)sender {
    [self activateEditModeWithRow:-1];
}

- (IBAction)onRegisterHook:(NSButton *)sender {
    NSInteger row = self->rowBeingEdited;
    self->rowBeingEdited = -1;
    [self updateHookAtTableRow:row];
}

- (IBAction)onHideEditBox:(NSButton *)sender {
    [self deactivateEditMode];
}

- (IBAction)onPause:(NSButton *)sender {
    [self toggleAllHooksActivation:NO];
    [self->hookTableView reloadData];
}

- (IBAction)onQuit:(NSButton *)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

- (IBAction)onProxyEventMouseBtn:(NSPopUpButton *)sender {
    self->mkmMode = ([sender indexOfSelectedItem] == MouseButtonTypeNone);
    if (self->mkmMode)
        [self clearModifierCheckBoxes];
    [self resetPressTypeMenu];
}

- (IBAction)onProxyEventModKeys:(NSButton *)sender {
    if (self->mkmMode && sender.state == NSOnState) {
        [self clearModifierCheckBoxes];
        (*self->proxyEventModKeyBtns[sender.tag]).state = NSOnState;
    }
}

#pragma mark TableRowModificationDelegate

- (void)editRow:(NSInteger)row {
    [self activateEditModeWithRow:row];
}

- (void)deleteRow:(NSInteger)row {
    [self deleteHookAtTableRow:row];
}

- (void)setRow:(NSInteger)row enabled:(BOOL)enable {
    [self turnHookAtTableRow:row asActive:enable];
}

@end
