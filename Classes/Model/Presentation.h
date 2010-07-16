//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationData;
@class PresentationContext;


@interface Presentation : NSObject <NSCoding> {
	BOOL selected;
	NSInteger presentationId;
	NSInteger index;
	
	PresentationData *data;
	PresentationContext *context;
	NSImage *thumbnail;
}

@property (assign) BOOL selected;
@property (assign) NSInteger presentationId;
@property (assign) NSInteger index;
@property (retain) PresentationContext *context;
@property (retain) PresentationData *data; 

@property (readonly) NSString *presentationFile;
@property (readonly) NSImage *thumbnail;

- (id) initWithId:(NSInteger)theId inContext: (PresentationContext *)theContext;

@end
