//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationDataContext.h"

@class PresentationLibrary;
@class FileCopyController;

@interface Presentation : NSObject <NSCoding, NSCopying> {
	BOOL selected;
	id presentationId;
	NSInteger index;
	
	id <PresentationDataContext> context;
	NSImage *thumbnail;
    NSImage *highlight_icon;
	
	FileCopyController *copyController;
}

@property (assign) BOOL selected;
@property (assign) NSInteger index;
@property (retain) id presentationId;
@property (retain) id<PresentationDataContext> context;

@property (retain) NSString *title;
@property (readonly) NSString *singleLineTitle;

@property (assign) BOOL highlight;

@property (retain) NSString *relativeThumbnailPath;
@property (readonly) NSString *absoluteThumbnailPath;

@property (retain) NSString *relativePresentationPath;
@property (readonly) NSString *absolutePresentationPath;

@property (readonly) BOOL presentationFileExists;
@property (readonly) NSImage *thumbnail;
@property (readonly) BOOL isComplete;

- (id) initWithId:(id)theId inContext: (id<PresentationDataContext>)theContext;

- (BOOL) updateFromPresentation: (Presentation*) other newThumbnailPath: (NSString*) thumbnailFile
				 newKeynotePath: (NSString*) keynoteFile copyController: (FileCopyController *)controller;
- (NSXMLElement*) xmlNode;

@end
