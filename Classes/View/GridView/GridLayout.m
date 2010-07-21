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
@synthesize viewPort;
@synthesize itemSize;

@synthesize border;

- (void)calculate {		
	[self calculateViewPortWithSuggestedRect: [self suggestedRectForFrame: self.viewFrame]];
}

- (NSInteger)cols {
	return [self colsForWidth: viewPort.size.width];
}

- (NSInteger)rows {
	return [self rowsForHeight: viewPort.size.height];
}

- (NSInteger)colsForWidth: (CGFloat)width {
	return (border + width) / (border + itemSize.width);
}

- (NSInteger)rowsForHeight: (CGFloat)height {
	return (border + height) / (border + itemSize.height); 
}

- (NSInteger)itemsOnPage {
	return self.cols * self.rows;
}

- (CGPoint)positionForItem: (NSInteger)index {
	CGPoint position;
	NSInteger col = index % [self cols];
	NSInteger row = index / [self cols];

	position.x = viewPort.origin.x + itemSize.width / 2 + (col * (itemSize.width + border));
	position.y = self.viewFrame.size.height - (itemSize.height / 2 + viewPort.origin.y + row * (itemSize.height + border));
	
	return position;
}

- (CGRect)suggestedRectForFrame: (CGRect) frame {
	return CGRectMake(0, 0, frame.size.width * 0.85, frame.size.height * 0.7); 
}

#pragma mark -
#pragma mark Layout Calculation Methods
- (void)calculateViewPortWithSuggestedRect: (CGRect)frame {
	NSInteger rows = [self rowsForHeight: frame.size.height];
	NSInteger cols = [self colsForWidth: frame.size.width];
	
	CGFloat width = cols * self.itemSize.width + (cols - 1) * border;
	CGFloat height = rows * self.itemSize.height + (rows - 1) * border;
	
	CGFloat horizontalMargin = (self.viewFrame.size.width - width) * 0.5;
	CGFloat verticalMargin = (self.viewFrame.size.height - height) * 0.5;
	
	viewPort = CGRectMake(horizontalMargin, verticalMargin, width, height);
}


@end
