//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationData.h"
#import "PresentationContext.h"


@implementation Presentation

@synthesize selected;
@synthesize presentationId;
@synthesize context;
@synthesize data;

- (id)initWithId:(NSInteger)theId inContext: (PresentationContext *)theContext; {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.context = theContext;
		self.presentationId = theId;
	}
	
	return self;
}

-(NSString *) description {
	return [NSString stringWithFormat:@"%@", self.data.title];
}

- (PresentationData *)data {
	if (data == nil) {
		self.data = [context presentationDataWithId:self.presentationId];
	}
	
	return data;
}

- (NSImage *)thumbnail {
	NSString *filepath = [context.directory stringByAppendingPathComponent:self.data.thumbnailPath];
	NSLog(@"filepath: %@", filepath);
	
	return [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
}

- (void) dealloc {
	[data release];
	[context release];
	[super dealloc];
}


@end
