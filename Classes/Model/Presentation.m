//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationData.h"
#import "PresentationContext.h"


@implementation Presentation

@synthesize selected;
@synthesize presentationId;
@synthesize index;
@synthesize context;
@synthesize data;

- (id)initWithId:(NSInteger)theId inContext: (PresentationContext *)theContext; {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.context = theContext;
		self.presentationId = theId;
        self.index = -1;
		
		[self thumbnail];
	}
	
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.selected = [aDecoder decodeBoolForKey:@"selected"];
		self.presentationId = [aDecoder decodeIntegerForKey:@"presentationId"];
        self.index = [aDecoder decodeIntegerForKey:@"index"];
	}
	
	return self;
}

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithId:self.presentationId inContext:self.context];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:self.selected forKey:@"selected"];
	[aCoder encodeInteger:self.presentationId forKey:@"presentationId"];
	[aCoder encodeInteger:self.index forKey:@"index"];
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

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
	
	return self.presentationId == ((Presentation *)object).presentationId;
}


- (void) dealloc {
	[thumbnail release];
	[data release];
	[context release];
	[super dealloc];
}


@end
