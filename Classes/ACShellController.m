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

@implementation ACShellController
@synthesize presentations;

- (id) init {
	self = [super init];
	if (self != nil) {		
		PresentationContext *context = [[PresentationContext alloc] init];
		
		self.presentations = [context allPresentations];
	}
	
	return self;
}

- (void) dealloc {
	[presentations release];
	[super dealloc];
}


- (IBAction)play: (id)sender; {
	NSLog(@"selected: %@", [self selectedPresentations]);
}


- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	
	return [self.presentations filteredArrayUsingPredicate:selected];
}




@end
