//
//  LibraryServerViewItem.m
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "LibraryServerCollectionItem.h"
#import "LibraryServerView.h"

@implementation LibraryServerCollectionItem

- (void)setSelected: (BOOL) flag {
    [super setSelected: flag];
    [(LibraryServerView*)[self view] setSelected:flag];
    [(LibraryServerView*)[self view] setNeedsDisplay:YES];
}
@end
