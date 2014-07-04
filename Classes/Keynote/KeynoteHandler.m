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
@property (atomic, strong, readwrite) KeynoteApplication *application;
@property (atomic, assign, readwrite) BOOL presenting;
@property (atomic, assign) dispatch_queue_t presentationQueue;
@property (atomic, assign) int currentPresentationTicket;
@property (atomic, strong) NSTimer *timerObservePresentation;
@property (atomic, strong) KeynoteDocument *presentation;
@property (atomic, weak) id<KeynoteDelegate> delegate;
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

#pragma mark - Manage Keynote presentation

- (void)stop {
    [self nextPresentationTicket];
    [self stopObservingPresentation];
    [self.presentation stop];
    [self didStopPresentation];
}

- (void)play:(NSString *)file withDelegate:(id<KeynoteDelegate>)delegate {
    
    if (self.presenting) return;
    self.presenting = YES;
    self.presentation = nil;
    self.delegate = delegate;
    int ticket = [self nextPresentationTicket];
    NSURL *url = [NSURL fileURLWithPath: file];
    
	dispatch_async(self.presentationQueue, ^{
        
        NSLog(@"Loading: %@", url);
        KeynoteDocument *presentation = [self.application open:url];
        NSLog(@"  loaded.. (%@)", presentation.name);
        KeynoteSlide *firstSlide = [[presentation slides] firstObject];
        NSLog(@"  picked first slide.. (%lu)", [firstSlide slideNumber]);
        
        // Loading the presentation is the most time consuming task and can take
        // several seconds. The ScriptingBridge calls above are synchronous,
        // and after their execution we have to check whether this asynchronously
        // run block should still continue to run:
        if ([self presentationShouldStillRun:ticket]) {
            self.presentation = presentation;
            [presentation startFrom:firstSlide];
            NSLog(@"  started to play..");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startObservingPresentation];
                [delegate keynoteDidStartPresentation:self];
            });
        }
        else {
            NSLog(@"  abort, ticket invalid.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate keynoteDidStartPresentation:self];
                [delegate keynoteDidStopPresentation:self];
            });
        }
	});
}

- (BOOL)presentationShouldStillRun:(int)ticket {
    return ticket == self.currentPresentationTicket;
}

- (int)nextPresentationTicket {
    return ++self.currentPresentationTicket;
}

#pragma mark - Observing state of running presentation

- (void)startObservingPresentation {
    self.timerObservePresentation = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                                     target:self
                                                                   selector:@selector(monitorPresentationState:)
                                                                   userInfo:nil repeats:YES];
}

- (void)stopObservingPresentation {
    [self.timerObservePresentation invalidate];
    self.timerObservePresentation = nil;
}

- (void)monitorPresentationState:(NSTimer *)timer {
    if (![self keynoteIsPlaying]) {
        [self stopObservingPresentation];
        [self didStopPresentation];
    }
}

- (void)didStopPresentation {
    self.presenting = NO;
    self.presentation = nil;
    [self.delegate keynoteDidStopPresentation:self];
}

- (BOOL)keynoteIsPlaying {
    
    /**
     There is no official way to ask Keynote via Scripting Bridge whether it
     is playing a presentation or not.
     The currently least stupid solution is to ask the following question:
     - Does Keynote have a window without a close-button?
     */
    
    NSArray *closeables = [[self.application windows] arrayByApplyingSelector:@selector(closeable)];
    for (NSNumber *closeable in closeables) {
        if (![closeable boolValue]) return YES;
    }
    return NO;
}

#pragma mark - DEPRECATED

// DEPRECATED
- (BOOL)usesSecondaryMonitorForPresentation {
	NSUserDefaults * defaults = [[NSUserDefaults alloc] init];
	[defaults addSuiteNamed:@"com.apple.iWork.Keynote"];
	[defaults synchronize];
	return [[defaults objectForKey:@"PresentationModeUseSecondary"] boolValue];
}


@end
