//
//  Playlist.h
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Playlist : NSObject <NSCoding> {
	NSString *name;
	NSMutableArray *presentations;
	NSMutableArray *children;
}

@property (copy) NSString *name;
@property (retain) NSMutableArray *presentations;
@property (retain) NSMutableArray *children;

+ (Playlist *) playlistWithName: (NSString *)theName presentations: (NSMutableArray *)thePresentations children: (NSMutableArray *)theChildren;

@end
