//
//  GridLayout.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "GridLayout.h"


@implementation GridLayout

@synthesize viewFrame;
@synthesize itemSize;

@synthesize paddingHorizontal;
@synthesize paddingVertical;
@synthesize border;

- (void)calculate {	
	viewPort.origin.x = 0 + paddingHorizontal;
	viewPort.origin.y = 0 + paddingVertical;
	viewPort.size.width = viewFrame.size.width - 2 * paddingHorizontal;
	viewPort.size.height = viewFrame.size.height - 2 * paddingVertical;
}

- (NSInteger)cols {
	return viewPort.size.width / (itemSize.width);
}

- (NSInteger)rows {
	return viewPort.size.height / (itemSize.height);
}

- (NSInteger)itemsOnPage {
	return self.cols * self.rows;
}

- (CGPoint)positionForItem: (NSInteger)index {
	CGPoint position;
	NSInteger col = index % [self cols];
	NSInteger row = index / [self cols];

	position.x = viewPort.origin.x + itemSize.width / 2 + (col * (itemSize.width + border));
	position.y = viewPort.size.height - (itemSize.height / 2 + viewPort.origin.y + row * (itemSize.height + border));
	
	return position;
}


@end
