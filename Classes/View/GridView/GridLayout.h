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
	
	CGFloat paddingHorizontal;
	CGFloat paddingVertical;
	CGFloat border;

	@private
	CGRect viewPort;
}

@property (assign) CGRect viewFrame;
@property (assign) CGSize itemSize;

@property (assign) CGFloat paddingHorizontal;
@property (assign) CGFloat paddingVertical;
@property (assign) CGFloat border;

@property (readonly) NSInteger itemsOnPage;

- (void)calculate;
- (NSInteger)cols;
- (NSInteger)rows;
- (CGPoint)positionForItem: (NSInteger)index;

@end