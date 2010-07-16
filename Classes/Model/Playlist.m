//
//  Playlist.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

@synthesize name;
@synthesize presentations;
@synthesize children;

+ (Playlist *) playlistWithName: (NSString *)theName presentations: (NSMutableArray *)thePresentations children: (NSMutableArray *)theChildren {
	Playlist *playlist = [[Playlist alloc] init];
	
	playlist.name = theName;
	playlist.presentations = thePresentations;
	playlist.children = theChildren;
	
	return [playlist autorelease];
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
