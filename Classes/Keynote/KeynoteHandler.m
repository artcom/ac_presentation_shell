//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteHandler.h"


@implementation KeynoteHandler
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"] retain];			
		});
	}
	return self;
}

- (void)open: (NSString *)file {
	NSURL *url = [NSURL fileURLWithPath: file];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		KeynoteSlideshow *slideshow =  [application open:url];
		[slideshow start];
		dispatch_async(dispatch_get_main_queue(), ^{
			keynotePollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(isKeynotePlaying) userInfo:nil repeats:YES];
			if ([delegate respondsToSelector:@selector(didFinishStartingKeynote:)]) {
				[delegate didFinishStartingKeynote: self];
			}
		});
	});

}


- (void)isKeynotePlaying {
	BOOL playing = [application playing];
	
	if (!playing) {
		[keynotePollTimer invalidate];
		keynotePollTimer = nil;		
		
		if ([delegate respondsToSelector:@selector(keynoteDidStopPresentation:)]) {
			[delegate keynoteDidStopPresentation: self];
		}
	}
}


- (void) dealloc {
	[application release];
	[super dealloc];
}

@end
