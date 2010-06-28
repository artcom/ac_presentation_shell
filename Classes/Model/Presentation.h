//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Presentation : NSObject {
	BOOL selected;
	NSInteger presentationId;
}

@property (assign) BOOL selected;
@property (assign) NSInteger presentationId;

+ (Presentation *)presentationWithId: (NSInteger)aPresentationId;

@end
