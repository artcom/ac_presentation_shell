//
//  GridLayout.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GridLayout : NSObject {
	CGRect viewFrame;
	CGSize itemSize;
	
	CGFloat border;

	@private
	CGRect viewPort;
}

@property (assign) CGRect viewFrame;
@property (assign) CGSize itemSize;
@property (assign) CGRect viewPort; 

@property (assign) CGFloat border;

@property (readonly) NSInteger itemsOnPage;

- (void)calculate;
- (NSInteger)cols;
- (NSInteger)rows;

- (NSInteger)colsForWidth: (CGFloat)width;
- (NSInteger)rowsForHeight: (CGFloat)height;

- (CGPoint)positionForItem: (NSInteger)index;

- (void)calculateViewPortWithSuggestedRect: (CGRect)frame;

@end
