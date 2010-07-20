//
//  PresentationView.m
//  ACShell
//
//  Created by Robert Palmer on 05.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationView.h"
#import "GridView.h"
#import "PaginationView.h"
#import "PresentationWindowController.h"

@implementation PresentationView

@synthesize pagination;
@synthesize pagerButtons;
@synthesize gridView;
@synthesize logo;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
	}
    return self;
}

-(void) awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) 
												 name:NSViewFrameDidChangeNotification object:logo];	
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] set];
	NSRectFill(dirtyRect);
	
	NSLog(@"logo: %@", NSStringFromRect(logo.frame));

}

- (void) resizeWithOldSuperviewSize:(NSSize)oldSize {
	NSLog(@"resizing");
}

- (void)viewDidResize: (NSNotification *)aNotification {
	NSLog(@"resize notification");
	NSRect screenFrame = [[[self window] windowController] presentationScreenFrame];
	[gridView layoutForRect: screenFrame];
	
	NSRect gridFrame = gridView.frame;
	CGFloat verticalMargin = (screenFrame.size.height - gridFrame.size.height) * 0.5;
	
	// [gridView setFrameOrigin:NSMakePoint(gridView.frame.origin.x, verticalMargin)];
	
	CGFloat logoYOrigin = (verticalMargin * 1.5) + gridFrame.size.height - logo.frame.size.height / 2;
	logo.frame = NSMakeRect(gridFrame.origin.x, logoYOrigin , logo.frame.size.width, logo.frame.size.height);
	
	
	CGFloat pagerButtonsXOrigin = gridFrame.origin.x + gridFrame.size.width - pagerButtons.frame.size.width;
	[pagerButtons setFrameOrigin: NSMakePoint(pagerButtonsXOrigin, gridFrame.origin.y - 23 - pagerButtons.frame.size.height)];
	
	[pagination setFrameOrigin:NSMakePoint(gridFrame.origin.x + gridFrame.size.width + 20, gridView.frame.origin.y)];
}


@end
