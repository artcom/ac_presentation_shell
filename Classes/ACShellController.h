//
//  ACShellController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationWindowController;
@class PresentationContext;
@class Playlist;


@interface ACShellController : NSObject {
	PresentationContext *presentationContext;
	
	NSArray *presentations;
	NSMutableArray* categories;

	PresentationWindowController *presentationWindowController;
	NSOutlineView *playlistView;
	
	NSArrayController *presentationsArrayController;
	NSTreeController *playlistTreeController;
	NSWindow *syncWindow;
	NSProgressIndicator *progressSpinner;
	
	NSTask *rsyncTask;
}

@property (retain) PresentationContext *presentationContext;
@property (retain, nonatomic) NSArray *presentations;
@property (retain, nonatomic) NSMutableArray *categories;
@property (retain, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (retain, nonatomic) IBOutlet 	NSTreeController *playlistTreeController;
@property (retain, nonatomic) IBOutlet NSWindow *syncWindow;
@property (retain, nonatomic) IBOutlet NSProgressIndicator *progressSpinner;
@property (retain, nonatomic) IBOutlet NSOutlineView *playlistView;

- (IBAction)play: (id)sender;
- (IBAction)sync: (id)sender;
- (IBAction)abortSync: (id)sender;
- (IBAction)addPlaylist: (id)sender;

- (NSArray *)selectedPresentations;

@end
