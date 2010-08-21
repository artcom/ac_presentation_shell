//
//  PreferencePage.m
//  ACShell
//
//  Created by David Siegel on 8/21/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PreferencePage.h"


@implementation PreferencePage

- (id) initFromNib: (NSString*) nibFilename title: (NSString*) title 
          iconName: (NSString*) icon 
{
    self = [super initWithNibName: nibFilename bundle: nil];
    if (self != nil) {
        [self setTitle: title];
        iconName = [icon retain];
    }
    return self;
}

- (NSString*) toolbarItemIdentifier {
    return [self title];
}

- (NSString*) iconName {
    return iconName;
}

- (void) dealloc {
    [iconName release];
    
    [super dealloc];
}

@end
