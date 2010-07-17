//
//  Settings.m
//  ACShell
//
//  Created by David Siegel on 7/16/10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Settings.h"
#import "PresentationContext.h"
#import "Presentation.h"
#import "PresentationData.h"
#import "NSFileManager-DirectoryHelper.h"
#import "ACShellCollection.h"

@implementation Settings

@synthesize allPresentations;
@synthesize highlights;
@synthesize collections;

-(id) init {
    self = [super init];
    if (self != nil) {
        self.allPresentations = [[NSMutableArray alloc] init];
        self.highlights = [[NSMutableArray alloc] init];
        self.collections = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.allPresentations = [aDecoder decodeObjectForKey:@"allPresentations"];
		self.highlights = [aDecoder decodeObjectForKey:@"highlights"];
        self.collections = [aDecoder decodeObjectForKey:@"collections"];
	}
	
	return self;
}

- (void) dealloc {
    [allPresentations release];
    [highlights release];
    [collections release];
    
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {	
	[aCoder encodeObject: allPresentations forKey:@"allPresentations"];
	[aCoder encodeObject: highlights forKey:@"highlights"];
	[aCoder encodeObject: collections forKey:@"collections"];	
	
	NSLog(@"collections: %@", collections);
}

- (void)syncWithContext: (PresentationContext*) theContext {
    [theContext syncPresentations: allPresentations withPredicate: nil];
    [theContext syncPresentations: highlights withPredicate: [NSPredicate predicateWithFormat:@"data.highlight == YES"]];
	
	for (ACShellCollection *collection in collections) {
		[theContext dropStalledPresentations:collection.presentations];
		for (Presentation *presentation in collection.presentations) {
			presentation.context = theContext;
		}
	}
}

+ (NSString *)filePath {
	return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];
}

@end
