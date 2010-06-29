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


@interface Presentation : NSObject {
	BOOL selected;
	NSInteger presentationId;
	
	PresentationData *data;
	PresentationContext *context;
}

@property (assign) BOOL selected;
@property (assign) NSInteger presentationId;
@property (retain) PresentationContext *context;
@property (retain) PresentationData *data; 


- (id) initWithId:(NSInteger)theId inContext: (PresentationContext *)theContext;
- (NSImage *)thumbnail;

@end
