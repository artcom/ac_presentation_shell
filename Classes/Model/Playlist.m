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

+ (Playlist *) playlistWithName: (NSString *)theName presentations: (NSArray *)thePresentations children: (NSArray *)theChildren {
	Playlist *playlist = [[Playlist alloc] init];
	
	playlist.name = theName;
	playlist.presentations = [[thePresentations mutableCopy] autorelease];
	playlist.children = [[theChildren mutableCopy] autorelease];
	
	return [playlist autorelease];
}

- (void)dealloc {
	[name release];
	[presentations release];
	[children release];
	
	[super dealloc];
}


@end
