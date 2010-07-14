//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "KeynoteHandler.h"


@implementation KeynoteHandler
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"] retain];			
		});
		// [application activate];
	}
	return self;
}

- (void)open: (NSString *)file {
	NSLog(@"opening: %@ in %@", file, application);
	NSURL *url = [NSURL fileURLWithPath: file];
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		KeynoteSlideshow *slideshow =  [application open:url];
		[slideshow start];
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([delegate respondsToSelector:@selector(didFinishStartingKeynote:)]) {
				[delegate didFinishStartingKeynote: self];
			}
		});
	});

}

- (void) dealloc {
	[application release];
	[super dealloc];
}




@end
