//
//  GridViewTest.m
//  ACShell
//
//  Created by Robert Palmer on 06.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
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
	return nil;
}

@end



@interface GridViewTest : GHTestCase {
	
}
@end


@implementation GridViewTest

- (void)testPageCalculation {
	MockedDataSource *dataSource = [[MockedDataSource alloc] init];
	dataSource.items = 10;
	
	GridView *view = [[GridView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
	view.dataSource = dataSource;
	
	GHTestLog(@"pages: %d", view.pages);
	GHAssertEquals(view.pages, 10, nil);
}


@end
