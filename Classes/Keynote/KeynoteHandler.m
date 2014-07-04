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
@property (atomic, assign, readwrite) BOOL presenting;
@property (atomic, assign) int currentPresentationTicket;
@property (atomic, assign) dispatch_queue_t presentationQueue;
@property (atomic, strong) NSTimer *timer;
@property (atomic, strong) KeynoteDocument *presentation;
@end

@implementation KeynoteHandler

+ (KeynoteHandler *)sharedHandler {
	if (sharedInstance == nil) {
		sharedInstance = [[KeynoteHandler alloc] init];
	}
	
	return sharedInstance;
}

- (void)dealloc
{
    dispatch_release(_presentationQueue);
}

- (id)init {
	self = [super init];
	if (self != nil) {
        self.presenting = NO;
        self.currentPresentationTicket = 0;
        self.presentationQueue = dispatch_queue_create("de.artcom.acshell.presentation", NULL);
	}
	return self;
}

- (void)launchWithDelegate:(id<KeynoteDelegate>) delegate {
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

- (void)open:(NSString *)file {
	NSURL *url = [NSURL fileURLWithPath: file];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.application open:url];
	});
}

- (void)stop {
    [self.timer invalidate];
    [self.presentation stop];
    [self nextPresentationTicket];
    self.presenting = NO;
    self.presentation = nil;
    self.timer = nil;
}


- (void)play:(NSString *)file withDelegate:(id<KeynoteDelegate>)delegate {
    
    // TODO this whole method is terrible
    
    if (self.presenting) return;
    self.presenting = YES;
    self.presentation = nil;
    int ticket = [self nextPresentationTicket];
    NSURL *url = [NSURL fileURLWithPath: file];
    
	dispatch_async(self.presentationQueue, ^{
        
        NSLog(@"Loading: %@", url);
        KeynoteDocument *presentation = [self.application open:url];
        self.presentation = presentation;
        NSLog(@"  loaded.. (%@)", presentation.name);
        KeynoteSlide *firstSlide = [[presentation slides] firstObject];
        if (!firstSlide) {
            NSLog(@"  NO FIRST SLIDE?!?!?!");
            return;
        }
        NSLog(@"  picked first slide..");
        
        if ([self validPresentationTicket:ticket]) {
            
            [presentation startFrom:firstSlide];
            
            NSLog(@"  started to play..");

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"  start monitoring..");
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorPresentationState:) userInfo:delegate repeats:YES];
                [delegate keynoteDidStartPresentation:self];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"  abort, ticket invalid.");
//                [delegate didFinishStartingKeynote:self];
//                [delegate keynoteDidStopPresentation:self];
            });
        }
	});
}

- (BOOL)validPresentationTicket:(int)ticket {
    return ticket == self.currentPresentationTicket;
}

- (int)nextPresentationTicket {
    return ++self.currentPresentationTicket;
}

/**
 Called by timer set up in play:withDelegate while a presentation is playing
 */
- (void)monitorPresentationState:(NSTimer *)timer {
    
    if ([self keynoteIsPlaying]) {
        //NSLog(@"playing");
    }
    else {
		id<KeynoteDelegate> delegate = [timer userInfo];
        [timer invalidate];
        self.timer = nil;
        self.presenting = NO;
        NSLog(@"  finished, stop monitoring.");
        [delegate keynoteDidStopPresentation:self];
	}
}

- (BOOL)keynoteIsPlaying {
    
    /**
     Originally, ACShell used [self.application playing] to ask about this state.
     
     But, the API to ask a keynote application whether it is playing a presentation through
     'playing' does not officially exist anymore, see
     http://stackoverflow.com/questions/19543368/monitoring-keynote-6-presentation-using-scriptingbridge
     
     Looking at the latest generated header (sdef /Applications/Keynote.app/ | sdp -fh --basename Keynote)
     there is no official way at all to ask about that state.
    
     The currently least stupid solution is to ask the following question:
     - Does Keynote have a window without a close-button?
     */
    
    NSArray *closeables = [[self.application windows] arrayByApplyingSelector:@selector(closeable)];
    for (NSNumber *closeable in closeables) {
        if (![closeable boolValue]) {
            return YES;
        }
    }
    return NO;
}


// DEPRECATED
- (BOOL)usesSecondaryMonitorForPresentation {
	NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
	[defaults addSuiteNamed:@"com.apple.iWork.Keynote"];
	[defaults synchronize];
	return [[defaults objectForKey:@"PresentationModeUseSecondary"] boolValue];
}


@end
