//
//  PreferenceWindowController.m
//  ACShell
//
//  Created by David Siegel on 7/18/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACPreferenceWindowController.h"
#import "default_keys.h"
#import "ACPreferencePage.h"

@interface ACPreferenceWindowController () 

- (void) showPage: (id) sender;
+ (NSPanel*) preferenceWindow;

@end


@implementation ACPreferenceWindowController

- (id)initWithPages: (NSArray*) pages  {
    self = [super initWithWindow: [ACPreferenceWindowController preferenceWindow]];
    if (self != nil) {
        self.window.toolbar.delegate = self;
        if (@available(macOS 11.0, *)) {
            self.window.toolbarStyle = NSWindowToolbarStylePreference;
        }
        // TODO: check on 10.14
        preferencePages = pages;

        NSMutableArray * toolbarIds = [[NSMutableArray alloc] init];
        for (ACPreferencePage * page in preferencePages) {
            [toolbarIds addObject: [page toolbarItemIdentifier]];
        }
        
        toolbarIdentifiers = [[NSArray alloc] initWithArray: toolbarIds];
        
        int i = 0;
        for (ACPreferencePage * page in preferencePages) {
            [[[self window] toolbar] insertItemWithItemIdentifier: [page toolbarItemIdentifier] 
                                                          atIndex: i++];
        }
        ACPreferencePage * firstPage = [preferencePages objectAtIndex: 0];
        [[[self window] toolbar] setSelectedItemIdentifier: [firstPage toolbarItemIdentifier]];
        [self showPage: nil];
    }
    return self;
}


- (void) showPage: (id) sender {
    NSString * identifier = [[[self window] toolbar] selectedItemIdentifier];
    
    NSUInteger pageIndex = [preferencePages indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
        return [[(ACPreferencePage*)obj toolbarItemIdentifier] isEqual: identifier];
    }];
    if (pageIndex == NSNotFound) {
        NSLog(@"failed to find preference page for id %@", identifier);
        return;
    }
    ACPreferencePage * page = [preferencePages objectAtIndex: pageIndex];
    NSRect targetViewFrame = [[page view] frame];
    
    NSView * currentView = [[self window] contentView];
    NSRect currentViewFrame = [currentView frame];
    
    if (targetViewFrame.size.width == currentViewFrame.size.width &&
        targetViewFrame.size.height == currentViewFrame.size.height)
    {
        return;
    }
    
    NSRect currentWindowFrame = [[self window] frame];
    CGFloat toolbarHeight = currentWindowFrame.size.height - currentViewFrame.size.height;
    
    CGFloat delta = targetViewFrame.size.height - currentViewFrame.size.height;
    NSRect newWindowFrame = NSMakeRect(currentWindowFrame.origin.x, currentWindowFrame.origin.y - delta,
                                       targetViewFrame.size.width, toolbarHeight + targetViewFrame.size.height);

    NSView *contentView = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 0, 0)];
    self.window.contentView = contentView;
    [[self window] setFrame: newWindowFrame display:YES animate:YES];
    self.window.contentView = [page view];
}

#pragma mark -
#pragma mark NSToolbarDelegate Protocol Methods
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar {
    return toolbarIdentifiers;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar {
    return toolbarIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar*) toolbar {
    return toolbarIdentifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *toolbarItem = nil;
    
    NSUInteger pageIndex = [preferencePages indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
        return [[(ACPreferencePage*)obj toolbarItemIdentifier] isEqual: itemIdentifier];
    }];
    
    if (pageIndex != NSNotFound) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        ACPreferencePage * page = [preferencePages objectAtIndex: pageIndex];
        [toolbarItem setLabel: [page title]];
        [toolbarItem setPaletteLabel: [page title]];
        if (@available(macOS 11.0, *)) {
            [toolbarItem setImage:[NSImage imageWithSystemSymbolName:page.iconName accessibilityDescription:nil]];
        } else {
            [toolbarItem setImage:[NSImage imageNamed:page.iconName]];
        }
    }
    return toolbarItem;
}

- (void) toolbarWillAddItem:(NSNotification *)notification {
    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
    [addedItem setTarget:self];
    [addedItem setAction:@selector(showPage:)];
}

#pragma mark -
#pragma mark Class Methods
+ (NSPanel*) preferenceWindow {
    NSPanel * panel = [[NSPanel alloc] init];
    [panel setHidesOnDeactivate:NO];
    [panel setShowsToolbarButton: NO];
    [panel setStyleMask: [panel styleMask] | NSWindowStyleMaskMiniaturizable];
    NSRect frame = [panel frame];
    frame.size.width = 600;
    [panel setFrame: frame display: NO];
    [panel center];
    // TODO: fix me
    [panel setFrameAutosaveName: @"PreferenceWindow"];
    [panel setFrameUsingName: @"PreferenceWindow" force: YES];
    
    NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier: @"PreferenceWindowToolbar"];
    [toolbar setVisible: YES];
    [toolbar setAllowsUserCustomization: NO];
    [panel setToolbar: toolbar];
    
    return panel;
}


@end
