//
//  ACShellController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ACShellController.h"
#import "Presentation.h"
#import "PresentationContext.h"
#import "PresentationWindowController.h"

@implementation ACShellController
@synthesize presentations;

- (id) init {
	self = [super init];
	if (self != nil) {		
		PresentationContext *context = [[PresentationContext alloc] init];
		self.presentations = [context allPresentations];
		[context release];
		
		presentationWindowController = [[PresentationWindowController alloc] init];

	}
	
	return self;
}

- (void) dealloc {
	[presentations release];
	[presentationWindowController release];

	[super dealloc];
}


- (IBAction)play: (id)sender {	
	presentationWindowController.presentations = [self selectedPresentations];
	NSLog(@"self presenations: %@", [self selectedPresentations]);
	[presentationWindowController showWindow:nil];
}


- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	return [self.presentations filteredArrayUsingPredicate:selected];
}




@end
