//
//  GridView.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "GridViewDataSource.h"

@interface GridView : NSView {
	id <GridViewDataSource> dataSource;
}

@property (assign, nonatomic) id <GridViewDataSource> dataSource;

- (void)arrangeSublayer;

@end
