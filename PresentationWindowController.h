//
//  PresentationWindowController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Presentation.h"
#import "GridViewDataSource.h"
#import "GridViewDelegate.h"
@class KeynoteHandler;
@class GridView;
@class PaginationView;

@interface PresentationWindowController : NSWindowController <GridViewDataSource, GridViewDelegate> {
	KeynoteHandler *keynote;
	NSMutableArray *presentations;
	
	GridView *gridView;
	PaginationView *paginationView;
}

@property (retain) NSArray *presentations;
@property (retain) IBOutlet GridView *gridView;
@property (retain) IBOutlet PaginationView *paginationView;

@end
