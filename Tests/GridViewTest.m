//
//  GridViewTest.m
//  ACShell
//
//  Created by Robert Palmer on 06.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "GHUnit/GHUnit.h"
#import "GridViewDataSource.h"
#import "GridLayout.h"
#import "GridView.h"


@interface MockedDataSource : NSObject <GridViewDataSource> {
	NSInteger items;
}

@property (assign) NSInteger items;

- (NSInteger)numberOfItemsInGridView: (GridView *)aGridView;
- (CALayer *)gridView: (GridView *)aGridView layerForItemAtIndex: (NSInteger)index;

@end

@implementation MockedDataSource
@synthesize items;

- (NSInteger)numberOfItemsInGridView: (GridView *)aGridView; {
	return items;
}

- (CALayer *)gridView: (GridView *)aGridView layerForItemAtIndex: (NSInteger)index; {
	return [CALayer layer];
}

- (CGSize)sizeForItemInGridView: (GridView *)aGridView {
	return CGSizeMake(10, 10);
}

@end



@interface GridViewTest : GHTestCase {
	MockedDataSource *dataSource;
	GridView *view;
}
@end


@implementation GridViewTest

- (void)setUp {
	dataSource = [[MockedDataSource alloc] init];
	view = [[GridView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
	
	view.dataSource = dataSource;	
}

- (void)tearDown {
	[dataSource release];
	[view release];
}

- (void)testPageCalculation {	
	dataSource.items = 1;

	GHAssertEquals(view.pages, 1, nil);
}

- (void)testPageCalculationWithZeroItems {
	dataSource.items = 0;
	GHAssertEquals(view.pages, 0, nil);
}

- (void)testPageCalculationWithManyItems {
	dataSource.items = 201;
	GHAssertEquals(view.pages, 3, nil);
}

- (void)testPageCalculationWithTwoFullPages {
	dataSource.items = 200;
	GHAssertEquals(view.pages, 2, nil);
}

- (void)testNextPage {
	dataSource.items = 200;
	GHAssertEquals(view.pages, 2, nil);

	GHAssertEquals(view.page, 0, @"should be on first page");
	GHAssertTrue([view hasNextPage], @"should have next page");
	
	view.page = 1;
	GHAssertFalse([view hasNextPage], @"should not have next page");	
}

- (void)testPreviousPage {
	dataSource.items = 200;
	GHAssertEquals(view.pages, 2, nil);
	
	GHAssertEquals(view.page, 0, @"should be on first page");
	GHAssertFalse([view hasPreviousPage], @"should not have previous page");
	
	view.page = 1;
	GHAssertTrue([view hasPreviousPage], @"should have previous page");
}

- (void)testFirstElementOnPage {
	dataSource.items = 150;
	
	GHAssertEquals([view firstItemOnPage], 0, nil);
	view.page = 1;
	
	GHAssertEquals([view firstItemOnPage], 100, nil);
}

- (void)testLastElementOnPage {
	dataSource.items = 150;
	
	GHAssertEquals([view lastItemOnPage], 99, nil);
	view.page = 1;
	
	GHAssertEquals([view lastItemOnPage], 149, nil);
}

- (void)testAdaptingIndexToPage {
	dataSource.items = 150;
	
	GHAssertEquals([view indexOfItemOnPage:50], 50, nil);
	view.page = 1;
	GHAssertEquals([view indexOfItemOnPage:50], 150, nil);
}


@end
