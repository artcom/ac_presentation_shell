//
//  GridLayoutTest.m
//  ACShell
//
//  Created by Robert Palmer on 06.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHUnit/GHUnit.h"
#import "GridLayout.h"

@interface GridLayoutTest : GHTestCase {
	GridLayout *layout;
}

@end


@implementation GridLayoutTest

- (void)setUp {
	layout = [[GridLayout alloc] init];
}

- (void)tearDown {
}

- (void)testCalculate {
	
	layout.viewFrame = CGRectMake(0, 0, 100, 100);
	layout.itemSize = CGSizeMake(10, 10);
	[layout calculate];
	
	GHAssertEquals(10, [layout rows], @"should calculate right number of rows");
	GHAssertEquals(10, [layout cols], @"should calculate right number of cols");
	
	GHAssertEquals(100, [layout itemsOnPage], @"should calculate right number of items on page");
}

- (void)testPositionForItem {
	layout.viewFrame = CGRectMake(0, 0, 100, 100);
	layout.itemSize = CGSizeMake(10, 10);
	[layout calculate];

	GHAssertTrue(CGPointEqualToPoint(CGPointMake(5,  95), [layout positionForItem: 0]), @"first item in first row should be at 5, 95");
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(5,  85), [layout positionForItem:10]), @"first item in second row should be at 5, 85");
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(15, 95), [layout positionForItem: 1]), @"second item in first row should be at 15, 95");
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(95,  5), [layout positionForItem:99]), @"last item in first row should be at 95, 5");
}

- (void)testPositionForItemWithBorder {
	layout.viewFrame = CGRectMake(0, 0, 100, 100);
	layout.itemSize = CGSizeMake(10, 10);
	layout.border = 5;
	
	[layout calculate];
	
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(5,  95), [layout positionForItem: 0]), @"first item in first row should be at 5, 95");
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(5,  80), [layout positionForItem:10]), @"first item in second row should be at 5, 80");
	GHAssertTrue(CGPointEqualToPoint(CGPointMake(20, 95), [layout positionForItem: 1]), @"second item in first row should be at 15, 95");
}

@end
