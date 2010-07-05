//
//  GridView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "GridView.h"
#import "GridLayout.h"

@implementation GridView

@synthesize dataSource;
@synthesize delegate;
@synthesize page;

- (void)awakeFromNib {
	CALayer *rootLayer=[CALayer layer];
	CGColorRef whiteColor=CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
	rootLayer.backgroundColor=whiteColor;
	
	CGColorRelease(whiteColor);
	
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
		
	sublayers = [[NSMutableArray alloc] init];
	layout = [[GridLayout alloc] init];
	
	self.page = 0;
	[self arrangeSublayer];
}

- (void) mouseUp:(NSEvent *)theEvent {
	CALayer *clickedLayer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
	if (clickedLayer == self.layer) {
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(gridView:didClickedItemAtIndex:)]) {
		[self.delegate gridView:self didClickedItemAtIndex:[sublayers indexOfObject:clickedLayer] + self.page * layout.itemsOnPage];
	}
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];

	layout.viewFrame = NSRectToCGRect(self.frame);
	layout.itemSize = CGSizeMake(220, 100);
	layout.paddingVertical = 300;
	layout.paddingHorizontal = 250;
	
	[layout calculate];
	[self arrangeSublayer];
}

- (void)arrangeSublayer {
	for (CALayer *layer in sublayers) {
		[layer removeFromSuperlayer];
	}
	[sublayers removeAllObjects];
	
	NSInteger items = [dataSource numberOfItemsInGridView:self];
	NSInteger firstItem = self.page * layout.itemsOnPage;
	NSInteger lastItem = (((self.page + 1) * layout.itemsOnPage - 1) < items) ? ((self.page + 1) * layout.itemsOnPage) : items;
	NSLog(@"items on page %d - %d", firstItem, lastItem); 
	
	for (int i = firstItem; i < lastItem; i++) {
		CALayer *layer = [dataSource gridView:self layerForItemAtIndex:i];
		layer.position = [layout positionForItem:i % layout.itemsOnPage];
		
		[self.layer addSublayer:layer];	
		[sublayers addObject:layer];
	}
}

-(void) setPage:(NSInteger)newPage {
	[self willChangeValueForKey:@"page"];
	page = newPage;
	[self didChangeValueForKey:@"page"];
	[self arrangeSublayer];
}

@end
