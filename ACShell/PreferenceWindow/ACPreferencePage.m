//
//  PreferencePage.m
//  ACShell
//
//  Created by David Siegel on 8/21/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACPreferencePage.h"


@implementation ACPreferencePage

- (id)initFromNib:(NSString *)nibFilename title:(NSString *)title
         iconName:(NSString *)icon
{
    self = [super initWithNibName:nibFilename bundle:nil];

    if (self != nil) {
        [self setTitle:title];
        iconName = icon;
    }

    return self;
}

- (id)initWithView:(NSView *)aView title:(NSString *)title iconName:(NSString *)icon {
    self = [super init];

    if (self != nil) {
        [self setView:aView];
        [self setTitle:title];
        iconName = icon;
    }

    return self;
}

- (NSString *)toolbarItemIdentifier {
    return self.title;
}

- (NSString *)iconName {
    return iconName;
}

@end
