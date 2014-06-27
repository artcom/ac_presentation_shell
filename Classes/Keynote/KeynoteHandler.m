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
@synthesize application;

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
        self.application = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
        
        // To trigger startup of application we need to retrieve some values.
        NSString *version = self.application.version;
        BOOL isRunning = self.application.isRunning;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(keynoteAppDidLaunch:version:)]) {
                [delegate keynoteAppDidLaunch:isRunning version:version];
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
			[delegate keynoteDidStopPresentation: self];
		}
	}
}


- (BOOL)usesSecondaryMonitorForPresentation {
	NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
	[defaults addSuiteNamed:@"com.apple.iWork.Keynote"];
	[defaults synchronize];
	
	return [[defaults objectForKey:@"PresentationModeUseSecondary"] boolValue];
}


@end
