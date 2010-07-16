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
#import "Playlist.h"

@implementation Settings

@synthesize allPresentations;
@synthesize highlights;
@synthesize presets;

-(id) init {
    self = [super init];
    if (self != nil) {
        self.allPresentations = [[NSMutableArray alloc] init];
        self.highlights = [[NSMutableArray alloc] init];
        self.presets = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.allPresentations = [aDecoder decodeObjectForKey:@"allPresentations"];
		self.highlights = [aDecoder decodeObjectForKey:@"highlights"];
        self.presets = [aDecoder decodeObjectForKey:@"presets"];
	}
	
	return self;
}

- (void) dealloc {
    [allPresentations release];
    [highlights release];
    [presets release];
    
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	NSLog(@"presets: %@", presets);
	
	[aCoder encodeObject: allPresentations forKey:@"allPresentations"];
	[aCoder encodeObject: highlights forKey:@"highlights"];
	[aCoder encodeObject: presets forKey:@"presets"];	
}

- (void)syncWithContext: (PresentationContext*) theContext {
    [theContext syncPresentations: allPresentations withPredicate: nil];
    [theContext syncPresentations: highlights withPredicate: [NSPredicate predicateWithFormat:@"data.highlight == YES"]];
}

+ (NSString *)filePath {
	return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];
}

@end
