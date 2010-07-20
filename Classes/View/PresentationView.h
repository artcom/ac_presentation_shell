//
//  PresentationView.h
//  ACShell
//
//  Created by Robert Palmer on 05.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GridView;
@class PaginationView;


@interface PresentationView : NSView {
	PaginationView *pagination;
	NSView *pagerButtons;
	GridView *gridView;
	NSView *logo;
}

@property (retain) IBOutlet PaginationView *pagination;
@property (retain) IBOutlet NSView *pagerButtons;
@property (retain) IBOutlet NSView *logo;
@property (retain) IBOutlet GridView *gridView;


@end
