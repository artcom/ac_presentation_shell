//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationData.h"


@implementation Presentation

@synthesize selected;
@synthesize presentationId;
@synthesize data;

- (id) initWithData: (PresentationData *)theData {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.data = theData;
	}
	
	return self;
}

-(NSString *) description {
	return [NSString stringWithFormat:@"%@", self.data.title];
}

- (void) dealloc {
	[data release];
	[super dealloc];
}


@end
