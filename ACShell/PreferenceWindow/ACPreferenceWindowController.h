//
//  PreferenceWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/18/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ACPreferenceWindowController : NSWindowController <NSToolbarDelegate, NSAnimationDelegate> {
    NSArray *preferencePages;
    NSArray *toolbarIdentifiers;
}

- (id)initWithPages:(NSArray *)pages;

@end
