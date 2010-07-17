//
//  ACShellCollection.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ACShellCollection.h"

@implementation ACShellCollection

@synthesize name;
@synthesize presentations;
@synthesize children;

+ (ACShellCollection *) collectionWithName: (NSString *)theName presentations: (NSMutableArray *)thePresentations children: (NSMutableArray *)theChildren {
	ACShellCollection *collection = [[ACShellCollection alloc] init];
	
	collection.name = theName;
	collection.presentations = thePresentations;
	collection.children = theChildren;
	
	return [collection autorelease];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.presentations = [aDecoder decodeObjectForKey:@"presentations"];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.presentations forKey:@"presentations"];
}

- (void)dealloc {
	[name release];
	[presentations release];
	[children release];
	
	[super dealloc];
}


@end
