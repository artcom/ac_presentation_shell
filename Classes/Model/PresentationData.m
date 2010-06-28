//
//  PresentationData.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationData.h"


@implementation PresentationData

- (id)initWithXMLNode: (NSXMLElement *)aNode
{
	self = [super init];
	if (self != nil) {
		xmlNode = [aNode retain];
	}
	
	return self;
}

-(void) dealloc {
	[xmlNode release];
	
	[super dealloc];
}

-(NSString *) title {
	NSArray *titleNodes = [xmlNode nodesForXPath:@"title" error:nil];
	if ([titleNodes count] != 1) {
		[NSException raise:@"No Title attribute found in xml file" format:@""];
	} 
	 
	return [[titleNodes objectAtIndex: 0] stringValue];	
	
}

- (NSInteger) presentationId {
	NSXMLNode *titleNode = [xmlNode attributeForName:@"id"];
	
	return [[titleNode objectValue] intValue];	
}

-(NSString *) description {
	return [NSString stringWithFormat:@"%d - %@", self.presentationId, self.title];
}


@end
