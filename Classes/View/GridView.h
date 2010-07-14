//
//  GridView.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "GridViewDataSource.h"
#import "GridViewDelegate.h"
@class GridLayout;

@interface GridView : NSView {
	id <GridViewDataSource> dataSource;
	id <GridViewDelegate> delegate;

	GridLayout *layout;
	NSMutableArray *sublayers;

	CALayer *hoveredLayer;
	NSInteger hoveredItem;
	NSTrackingRectTag mouseTrackingRectTag;
	
	NSInteger page;
	BOOL mouseTracking;
}

@property (assign, nonatomic) id <GridViewDataSource> dataSource;
@property (assign, nonatomic) id <GridViewDelegate> delegate;
@property (assign, nonatomic) NSInteger page;
@property (assign, readonly) NSInteger pages;
@property (assign, getter=isMouseTracking) BOOL mouseTracking;
@property (retain) CALayer *hoveredLayer; 

- (void)arrangeSublayer;
- (BOOL)hasNextPage;
- (BOOL)hasPreviousPage;

- (NSInteger)lastItemOnPage;
- (NSInteger)firstItemOnPage;
- (NSInteger)indexOfItemOnPage: (NSInteger)index;

- (void)addOverlay: (CALayer *)newOverlay forItem: (NSInteger)index;


@end
