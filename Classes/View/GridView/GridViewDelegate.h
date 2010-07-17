//
//  GridViewDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol GridViewDelegate <NSObject>

@optional
- (void)gridView:(GridView *)aView didClickedItemAtIndex: (NSInteger)index; 
- (void)didUpdateGridView: (GridView *)aView;

@end
