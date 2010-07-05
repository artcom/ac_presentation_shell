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
		
		[self thumbnail];
	}
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@", self.data.title];
}

- (PresentationData *)data {
	if (data == nil) {
		self.data = [context presentationDataWithId:self.presentationId];
	}
	
	return data;
}

- (NSImage *)thumbnail {
	if (thumbnail == nil) {
		NSString *filepath = [context.directory stringByAppendingPathComponent:self.data.thumbnailPath];
		thumbnail =  [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];		
	}

	return thumbnail;
}

- (NSString *)presentationFile {
	return [self.context.directory stringByAppendingPathComponent:self.data.presentationPath];
}

- (void) dealloc {
	[thumbnail release];
	[data release];
	[context release];
	[super dealloc];
}


@end
