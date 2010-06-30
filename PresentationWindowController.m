//
//  PresentationWindowController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationWindowController.h"
#import "Presentation.h"
#import "PresentationData.h"
#import "KeynoteHandler.h"


@implementation PresentationWindowController

@synthesize presentations;

- (id) init {
	self = [super initWithWindowNibName:@"PresentationWindow"];
	if (self != nil) {
		keynote = [[KeynoteHandler alloc] init];
	}
	return self;
}

-(void) awakeFromNib {
	NSLog(@"%@", self.window);
	NSRect frame = [[[NSScreen screens] objectAtIndex:0] frame];
	NSLog(@"self.window.frame %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	frame = [[[NSScreen screens] objectAtIndex:1] frame];	
	NSLog(@"self.window.frame %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

	[self.window setFrame:[NSScreen mainScreen].frame display:YES animate: YES];
	[self.window makeKeyAndOrderFront:nil];
	
	@try {
		NSApplicationPresentationOptions options = NSApplicationPresentationHideDock + NSApplicationPresentationHideMenuBar;
		[NSApp setPresentationOptions:options];
	}
	@catch(NSException * exception) {
		NSLog(@"Error.  Make sure you have a valid combination of options.");
	}
}


#pragma mark -
#pragma mark GridView DataSource
-(NSInteger) numberOfItemsInGridView:(GridView *)aGridView {
	return [self.presentations count];
}

-(CALayer *) gridView:(GridView *)aGridView layerForItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	NSImage *image = presentation.thumbnail;
	
	CALayer *layer = [CALayer layer];
	layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.contents = image;
	
	return layer;
}

#pragma mark -
#pragma mark GridView Delegate
-(void) gridView:(GridView *)aView didClickedItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	
	[keynote open: presentation.presentationFile];
}


@end
