//
//  PresentationWindow.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PaginationView;


@interface PresentationWindow : NSWindow {
	PaginationView *paginationView;
}

@property (retain) IBOutlet PaginationView *paginationView;

@end
