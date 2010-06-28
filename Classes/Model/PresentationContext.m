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


@implementation PresentationContext

- (id)init {
	self = [super init];
	if (self != nil) {
		presentations = [[NSMutableDictionary alloc] init];
		
		NSURL *xmlURL = [[NSBundle mainBundle] URLForResource:@"demo_library" withExtension:@"xml"];
		
		NSError *error = nil;
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:xmlURL options:0 error:&error];
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
	[presentations release];
	[super dealloc];
}

- (NSArray *)allPresentations {
	NSMutableArray *allPresentations = [NSMutableArray array];
	for (PresentationData *data in [presentations allValues]) {
		Presentation *presentation = [[[Presentation alloc] initWithData:data] autorelease];
		[allPresentations addObject:presentation];
	}
	
	return allPresentations;
}

- (PresentationData *)presentationDataWithId: (NSInteger)aId {
	return [presentations objectForKey:[NSNumber numberWithInt:aId]];
}


@end
