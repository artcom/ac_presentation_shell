//
//  ACShellCollection.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellCollection.h"
#import "Presentation.h"

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

+ (ACShellCollection *) collectionWithName: (NSString *)theName {
	ACShellCollection *collection = [[ACShellCollection alloc] init];
	
	collection.name = theName;
	collection.presentations = [NSMutableArray  array];
	collection.children = [NSMutableArray array];
	
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

- (void) assignContext: (id) context {
    for (ACShellCollection * c in children) {
        [c assignContext: context];
    }
    for (Presentation * p in presentations) {
        p.context = context;
    }    
}

@end
