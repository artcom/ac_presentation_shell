//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteHandler.h"

KeynoteHandler *sharedInstance;

@implementation KeynoteHandler

+ (KeynoteHandler *)sharedHandler {
	if (sharedInstance == nil) {
		sharedInstance = [[KeynoteHandler alloc] init];
	}
	
	return sharedInstance;
}


- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (void) launchWithDelgate: (id<KeynoteDelegate>) delegate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"] retain];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(keynoteAppDidLaunch:)]) {
                [delegate keynoteAppDidLaunch: application != nil];
            }
        });          
        
    });
}

- (void)play: (NSString *)file withDelegate: (id<KeynoteDelegate>) delegate {
	NSURL *url = [NSURL fileURLWithPath: file];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		KeynoteSlideshow *slideshow =  [application open:url];
		[[slideshow.slides objectAtIndex:0] startFrom];
		// [slideshow start];
		dispatch_async(dispatch_get_main_queue(), ^{
			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(isKeynotePlaying:) userInfo: delegate repeats:YES];
            
			if ([delegate respondsToSelector:@selector(didFinishStartingKeynote:)]) {
                NSLog(@"==== keynote started ====");
				[delegate didFinishStartingKeynote: self];
			}
		});
	});

}


- (void)open: (NSString *)file {
	NSURL *url = [NSURL fileURLWithPath: file];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[application open:url];
	});	
}


- (void)isKeynotePlaying: (NSTimer *)timer {
	BOOL playing = [application playing];
	
	if (!playing) {
		id<KeynoteDelegate> delegate = [timer userInfo];
		[timer invalidate];
		if ([delegate respondsToSelector:@selector(keynoteDidStopPresentation:)]) {
            NSLog(@"==== keynote stopped ====");
			[delegate keynoteDidStopPresentation: self];
		}
	}
}

- (void) dealloc {
	[application release];
	[super dealloc];
}

- (BOOL)usesSecondaryMonitorForPresentation {
	NSUserDefaults * defaults = [[[NSUserDefaults alloc] init] autorelease];
	[defaults addSuiteNamed:@"com.apple.iWork.Keynote"];
	[defaults synchronize];
	
	return [[defaults objectForKey:@"PresentationModeUseSecondary"] boolValue];
}


@end
