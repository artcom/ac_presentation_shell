//
//  ACShellController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ACShellController.h"
#import "Presentation.h"

@implementation ACShellController
@synthesize presentations;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.presentations = [NSMutableArray arrayWithObjects:
							  [Presentation presentationWithId:0],
							  [Presentation presentationWithId:1],
							  [Presentation presentationWithId:2], nil];
	}
	
	return self;
}


@end
