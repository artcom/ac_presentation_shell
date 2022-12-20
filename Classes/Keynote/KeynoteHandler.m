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
@property (atomic, assign) int currentPresentationTicket;
@property (atomic, strong) NSTimer *timerObservePresentation;
@property (atomic, strong) KeynoteDocument *presentation;
@property (atomic, weak) id<KeynoteDelegate> delegate;
@end

@implementation KeynoteHandler

+ (KeynoteHandler *)sharedHandler {
    if (sharedInstance == nil) {
        sharedInstance = KeynoteHandler.new;
    }
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.presenting = NO;
        self.currentPresentationTicket = 0;
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
    [self presentationDidStop];
}

- (void)play:(NSString *)file withDelegate:(id<KeynoteDelegate>)delegate {
    
    if (self.presenting) return;
    self.presenting = YES;
    self.presentation = nil;
    self.delegate = delegate;
    int ticket = [self nextPresentationTicket];
    NSURL *url = [NSURL fileURLWithPath: file];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Loading presentation: %@", url);
        KeynoteDocument *presentation = [self.application open:url];
        NSLog(@"  loaded.. (%@)", [presentation name]);
        
        // Loading the presentation as well as picking the first slide can take several seconds.
        // While these ScriptingBridge calls are synchronous, after
        // their execution we have to check whether this asynchronously
        // run block as a whole should still continue to run:
        KeynoteSlide *firstSlide;
        if (presentation && [self presentationShouldStillRun:ticket]) {
            firstSlide = [[presentation slides] firstObject];
            NSLog(@"  picked first slide.. (%lu)", [firstSlide slideNumber]);
        }
        
        // Check again after picking first slide
        if (presentation && [self presentationShouldStillRun:ticket]) {
            self.presentation = presentation;
            [presentation startFrom:firstSlide];
            NSLog(@"  started to play..");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startObservingPresentation];
                [delegate keynoteDidStartPresentation:self];
            });
        }
        else {
            NSLog(@"  cancelled.");
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
        [self presentationDidStop];
    }
}

- (void)presentationDidStop {
    NSLog(@"  stopped.");
    [self.presentation closeSaving:KeynoteSaveOptionsNo savingIn:nil];
    self.presenting = NO;
    self.presentation = nil;
    [self.delegate keynoteDidStopPresentation:self];
}

- (BOOL)keynoteIsPlaying {
    /**
     03/07/2014:
     There is no official way to ask Keynote via Scripting Bridge whether it is currently playing a presentation or not.
     Today's least stupid solution is to ask the following question:
     - Does Keynote have a window without a close-button? (Because that would be a presentation window)
     About why we use arrayByApplyingSelector see ScriptingBridge documentation on how to iterate over SBArrays ideally.
     
     17/11/2022:
     Now this check only works when applied on the first entry in the SBArray. This depends on the window herarchy which in turn depends on use on primary/secondary screen.
     
     28/11/2022:
     It seems to be better to use the documents property of each window.
     If there is more than one window for a given document, this means that this document is displayed in an edit window AND in a presentation window.
     */
    NSMutableArray *documentIds = [NSMutableArray new];
    NSArray *documents = [[self.application windows] arrayByApplyingSelector:@selector(document)];
    for (KeynoteDocument *document in documents) {
        NSString *documentId = [document id];
        if ([documentIds containsObject:documentId]) {
            return YES;
        }
        [documentIds addObject:documentId];
    }
    return NO;
}

@end
