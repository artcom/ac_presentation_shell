//
//  PresentationView.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PresentationViewDataSource.h"
#import "PresentationViewDelegate.h"
@class GridLayout;
@class PaginationView;

@interface PresentationView : NSView {
	id <PresentationViewDataSource> dataSource;
	id <PresentationViewDelegate> delegate;

	GridLayout *layout;
	NSMutableArray *sublayers;

	CALayer *hoveredLayer;
	NSInteger hoveredItem;
	NSTrackingRectTag mouseTrackingRectTag;
	
	NSInteger page;
	BOOL mouseTracking;
	
	CALayer *logo;
	PaginationView *paginationView;
	NSButton *pageButtons;
}

@property (assign, nonatomic) id <PresentationViewDataSource> dataSource;
@property (assign, nonatomic) id <PresentationViewDelegate> delegate;
@property (assign, nonatomic) NSInteger page;
@property (assign, readonly) NSInteger pages;
@property (assign, nonatomic, getter=isMouseTracking) BOOL mouseTracking;
@property (retain) CALayer *hoveredLayer; 
@property (retain) GridLayout *layout;
@property (retain) CALayer *logo;

- (void)arrangeSublayer;
- (BOOL)hasNextPage;
- (BOOL)hasPreviousPage;

- (NSInteger)lastItemOnPage;
- (NSInteger)firstItemOnPage;
- (NSInteger)indexOfItemOnPage: (NSInteger)index;

- (void)addOverlay: (CALayer *)newOverlay forItem: (NSInteger)index;

@end
