//
//  GridViewDataSource.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
@class GridView;

@protocol GridViewDataSource

- (NSInteger)numberOfItemsInGridView: (GridView *)aGridView;
- (CALayer *)gridView: (GridView *)aGridView layerForItemAtIndex: (NSInteger)index;

@end
