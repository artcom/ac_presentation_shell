//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"

@class PresentationLibrary;
@class FileCopyController;

@interface Presentation : NSObject <NSCoding, NSCopying> {
	BOOL selected;
	id presentationId;
	NSInteger index;
	
	PresentationLibrary* context;
	NSImage *thumbnail;
    NSImage *highlight_icon;
	
	FileCopyController *copyController;
	
    NSString * title;
	NSString * presentationFilename;
	NSString * thumbnailFilename;
}

@property (assign) BOOL selected;
@property (assign) NSInteger index;
@property (retain) id presentationId;
@property (retain) PresentationLibrary* context;

@property (retain) NSString *title;
@property (readonly) NSString *singleLineTitle;

@property (assign) BOOL highlight;

@property (retain)   NSString * directory;
@property (readonly) NSString * absoluteDirectory;

@property (retain)   NSString * thumbnailFilename;
@property (readonly) NSString * relativeThumbnailPath;
@property (readonly) NSString * absoluteThumbnailPath;

@property (retain)   NSString * presentationFilename;
@property (readonly) NSString * relativePresentationPath;
@property (readonly) NSString * absolutePresentationPath;

@property (readonly) BOOL presentationFileExists;
@property (readonly) BOOL thumbnailFileExists;

@property (readonly) NSImage *thumbnail;
@property (readonly) BOOL isComplete;

- (id) initWithId:(id)theId inContext: (PresentationLibrary*)theContext;

- (NSXMLElement*) xmlNode;

@end
