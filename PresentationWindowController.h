//
//  PresentationWindowController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Presentation.h"
#import "GridViewDataSource.h"
#import "GridViewDelegate.h"

@interface PresentationWindowController : NSWindowController <GridViewDataSource, GridViewDelegate> {
	NSArray *presentations;
}

@property (retain) NSArray *presentations;


@end
