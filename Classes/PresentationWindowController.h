//
//  PresentationWindowController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Presentation.h"
#import "GridViewDataSource.h"
#import "GridViewDelegate.h"
#import "KeynoteDelegate.h"

@class KeynoteHandler;
@class GridView;
@class PaginationView;

@interface PresentationWindowController : NSWindowController <GridViewDataSource, GridViewDelegate, KeynoteDelegate> {
	KeynoteHandler *keynote;
	NSMutableArray *presentations;
	
	GridView *gridView;
}

@property (retain) NSArray *presentations;
@property (retain) IBOutlet GridView *gridView;

- (NSRect)presentationScreenFrame;


@end
