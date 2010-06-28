//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationData;


@interface Presentation : NSObject {
	BOOL selected;
	NSInteger presentationId;
	
	PresentationData *data;
}

@property (assign) BOOL selected;
@property (assign) NSInteger presentationId;
@property (retain) PresentationData *data; 

- (id) initWithData: (PresentationData *)theData;

@end
