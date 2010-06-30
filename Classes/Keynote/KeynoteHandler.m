//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "KeynoteHandler.h"


@implementation KeynoteHandler

- (id) init {
	self = [super init];
	if (self != nil) {
		application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"] retain];
		NSLog(@"application: %@", application);
		[application activate];
	}
	return self;
}

- (void)open: (NSString *)file {
	NSLog(@"opening: %@ in %@", file, application);
	NSURL *url = [NSURL fileURLWithPath: file];
	KeynoteSlideshow *slideshow =  [application open:url];
	[slideshow start];
}

- (void) dealloc {
	[application release];
	[super dealloc];
}




@end
