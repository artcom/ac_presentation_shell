//
//  PresentationWindowController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LibraryCategory.h"
#import "Presentation.h"
#import "PresentationIntroViewDataSource.h"
#import "PresentationIntroViewDelegate.h"
#import "PresentationViewDataSource.h"
#import "PresentationViewDelegate.h"
#import "KeynotePlaybackDelegate.h"

@class KeynoteHandler;
@class PresentationIntroView;
@class PresentationView;
@class PaginationView;

@interface PresentationWindowController : NSWindowController
<PresentationViewDataSource, PresentationViewDelegate,
PresentationIntroViewDataSource, PresentationIntroViewDelegate,
KeynotePlaybackDelegate, NSWindowDelegate>

@property (nonatomic, strong) KeynoteHandler *keynote;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *presentations;

@property (weak) IBOutlet NSView *presentationContainerView;
@property (weak) IBOutlet PresentationIntroView *presentationIntroView;
@property (weak) IBOutlet PresentationView *presentationView;

- (NSRect)presentationScreenFrame;
- (void)abortIfNecessary;
@end
