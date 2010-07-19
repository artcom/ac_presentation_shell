//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationLibrary;


@interface Presentation : NSObject <NSCoding, NSCopying> {
	BOOL selected;
	id presentationId;
	NSInteger index;
	
	PresentationLibrary *context;
	NSImage *thumbnail;
    NSImage *highlight_icon;
}

@property (assign) BOOL selected;
@property (assign) id presentationId;
@property (assign) NSInteger index;
@property (retain) PresentationLibrary *context;


@property (readonly) NSString *title;
@property (readonly) BOOL highlight;
@property (readonly) NSString *thumbnailPath;
@property (readonly) NSString *presentationPath;

@property (readonly) NSString *presentationFile;
@property (readonly) NSImage *thumbnail;

- (id) initWithId:(id)theId inContext: (PresentationLibrary *)theContext;

@end
