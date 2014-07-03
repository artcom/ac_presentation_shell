//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteHandler.h"

KeynoteHandler *sharedInstance;

@interface KeynoteHandler ()
@property (strong) KeynoteDocument *currentDocument;
@end

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

- (void)play:(NSString *)file withDelegate:(id<KeynoteDelegate>)delegate {
	NSURL *url = [NSURL fileURLWithPath: file];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        KeynoteDocument *slideshow =  [self.application open:url];
        KeynoteSlide *firstSlide = [[slideshow slides] firstObject];
		[slideshow startFrom:firstSlide];
		dispatch_async(dispatch_get_main_queue(), ^{
			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorPresentationState:) userInfo: delegate repeats:YES];
            
			if ([delegate respondsToSelector:@selector(didFinishStartingKeynote:)]) {
				[delegate didFinishStartingKeynote: self];
			}
		});
	});

}


- (void)open: (NSString *)file {
	NSURL *url = [NSURL fileURLWithPath: file];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.application open:url];
	});	
}

- (BOOL)keynoteIsPlaying {
    
    /**
     Originally, ACShell used [self.application playing] to ask about this state.
     
     But, the API to ask a keynote application whether it is playing a presentation through
     'playing' does not officially exist anymore, see
     http://stackoverflow.com/questions/19543368/monitoring-keynote-6-presentation-using-scriptingbridge
     
     Looking at the latest generated header (sdef /Applications/Keynote.app/ | sdp -fh --basename Keynote)
     there is no official way at all to ask about that state anymore.
    
     The currently least stupid solution is to ask the following question:
     - Does Keynote have a window without a close-button?
     */
    
    NSArray *windows = [[self.application windows] get];
    for (KeynoteWindow *window in windows) {
        if (!window.closeable) return YES;
    }
    return NO;
}

- (void)monitorPresentationState:(NSTimer *)timer {
	if (![self keynoteIsPlaying]) {
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
