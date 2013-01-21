//
//  PresentationWindowController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Presentation.h"
#import "PresentationViewDataSource.h"
#import "PresentationViewDelegate.h"
#import "KeynoteDelegate.h"

@class KeynoteHandler;
@class PresentationView;
@class PaginationView;

@interface PresentationWindowController : NSWindowController <PresentationViewDataSource, PresentationViewDelegate, KeynoteDelegate> {
	KeynoteHandler *keynote;
	NSMutableArray *presentations;
	
	PresentationView *presentationView;
	
//	NSInteger playingKeynote;
}

@property (nonatomic, retain) NSArray *presentations;
@property (retain) IBOutlet PresentationView *presentationView;

- (NSRect)presentationScreenFrame;


@end
