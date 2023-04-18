//
//  KeynoteHandler.m
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteHandler.h"
#import "default_keys.h"

KeynoteHandler *sharedInstance;

@interface KeynoteHandler ()
@property (atomic, strong, readwrite) KeynoteApplication *application;
@property (atomic, assign, readwrite) BOOL presenting;
@property (atomic, assign) int currentPresentationTicket;
@property (atomic, strong) NSTimer *timerObservePresentation;
@property (atomic, strong) KeynoteDocument *presentation;
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

- (void)launch {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.application = [SBApplication applicationWithBundleIdentifier:ACShellKeynoteDefaultDomain];
        
        // To trigger startup of application we need to retrieve some values.
        NSString *version = self.application.version;
        BOOL isRunning = self.application.isRunning;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.launchDelegate respondsToSelector:@selector(keynoteAppDidLaunch:version:)]) {
                [self.launchDelegate keynoteAppDidLaunch:isRunning version:version];
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

- (void)play:(NSString *)file withDelegate:(id<KeynotePlaybackDelegate>)delegate {
    
    if (self.presenting) return;
    self.delegate = delegate;
    self.presenting = YES;
    self.presentation = nil;
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
            
            if ([self keynoteIsPlayingFullscreen]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startObservingPresentation];
                    [delegate keynoteDidStartPresentation:self];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.launchDelegate keynoteDidRunInWindow:self];
                });
            }
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

- (BOOL)keynoteIsPlayingFullscreen
{
    NSMutableArray *windows = NSMutableArray.new;
    [self.application.windows enumerateObjectsUsingBlock:^(KeynoteWindow *_Nonnull window, NSUInteger index, BOOL *_Nonnull stop) {
        NSRange range = [window.name rangeOfString:@".key"];
        if (range.length > 0) {
            [windows addObject:window];
        }
    }];
    
    __block BOOL noncloseable = NO;
    __block BOOL nonresizable = NO;
    __block BOOL nonzoomable = NO;
    [windows enumerateObjectsUsingBlock:^(KeynoteWindow   * _Nonnull window, NSUInteger index, BOOL * _Nonnull stop) {
        if(!window.closeable) noncloseable = YES;
        if(!window.resizable) nonresizable = YES;
        if(!window.zoomable) nonzoomable = YES;
    }];
    
    return (noncloseable && nonresizable && nonzoomable);
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
    NSArray *documents = [self.application.windows arrayByApplyingSelector:@selector(document)];
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
