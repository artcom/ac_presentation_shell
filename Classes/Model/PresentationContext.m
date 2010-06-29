//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationContext.h"
#import "PresentationData.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"

@implementation PresentationContext
@synthesize directory;

- (id)init {
	self = [super init];
	if (self != nil) {
		presentations = [[NSMutableDictionary alloc] init];

		self.directory = [[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain];
		NSString *libraryPath = [self.directory stringByAppendingPathComponent:@"library.xml"];
		#pragma mark TODO: check if file exists and offer option or hint for first sync.
		
		NSError *error = nil;
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error];
		NSArray *xmlPresentations = [document nodesForXPath:@"./presentations/presentation" error:&error];

		for (NSXMLElement *presentation in xmlPresentations) {
			PresentationData *data = [[PresentationData alloc] initWithXMLNode:presentation];
			[presentations setObject: data forKey: [NSNumber numberWithInt: [data presentationId]]];			
			
			[data release];
		}
	}
	
	return self;
}

- (void) dealloc {
	[directory release];
	[presentations release];
	[super dealloc];
}

- (NSArray *)allPresentations {
	NSMutableArray *allPresentations = [NSMutableArray array];
	for (PresentationData *data in [presentations allValues]) {
		Presentation *presentation = [[[Presentation alloc] initWithId: data.presentationId inContext:self] autorelease];
		[allPresentations addObject:presentation];
	}
	
	return allPresentations;
}

- (PresentationData *)presentationDataWithId: (NSInteger)aId {
	return [presentations objectForKey:[NSNumber numberWithInt:aId]];
}


@end
