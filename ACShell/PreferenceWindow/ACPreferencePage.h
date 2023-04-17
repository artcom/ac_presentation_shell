//
//  PreferencePage.h
//  ACShell
//
//  Created by David Siegel on 8/21/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACPreferencePage : NSViewController {
    NSString * iconName;
}

- (id) initFromNib: (NSString*) nibFilename title: (NSString*) title iconName: (NSString*) icon;
- (id) initWithView: (NSView*) aView title: (NSString*) title iconName: (NSString*) icon;

- (NSString*) toolbarItemIdentifier;
- (NSString*) iconName;
@end
