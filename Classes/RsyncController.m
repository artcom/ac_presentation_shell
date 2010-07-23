//
//  RsyncController.m
//  rsync_controller
//
//  Created by David Siegel on 7/20/10.
//  Copyright 2010 ART+COM. All rights reserved.
//

#import "RsyncController.h"
#import "RsyncTask.h"

@interface RsyncController ()

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) userDidConfirmAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) userDidConfirmInitialSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(NSImage*) syncIcon;
-(void) performSync: (NSString*) source destination: (NSString*) destination;


-(NSAlert*) progressDialog;
-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText style: (NSAlertStyle) style icon: (NSImage*) icon;
-(NSAlert*) acknowledgeDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText style: (NSAlertStyle) style icon: (NSImage*) icon;
-(void)showSheet: (NSAlert*) sheet didEndSelector: (SEL)theEndSelector context: (void*) context;


@end

static NSImage * ourSyncIcon = nil;

@implementation RsyncController
@synthesize delegate;
@synthesize documentWindow;

- (id) init {
    self = [super init];
    if (self != nil) {
    }
    return self;   
}

-(void) dealloc {
    
    [super dealloc];
}

- (void) syncWithSource: (NSString*) source destination: (NSString*) destination {
    [self performSync: source destination: destination];
}

-(void) initialSyncWithSource: (NSString*) source destination: (NSString*) destination {
    NSAlert * confirm = [self confirmDialogWithMessage: @"Synchronize library now?"
                                     informationalText: @"A good network connection and some patience is required."
                                                 style: NSInformationalAlertStyle
                                                  icon: [self syncIcon]];
    NSArray * srcDst = [[NSArray arrayWithObjects: source, destination, nil] retain];
    [self showSheet: confirm didEndSelector: @selector(userDidConfirmInitialSync:returnCode:contextInfo:) context: srcDst];
}

-(void) performSync: (NSString*) source destination: (NSString*) destination {
    NSAlert * progressDialog = [self progressDialog];
    [self showSheet: progressDialog didEndSelector: @selector(userDidAbortSync:returnCode:contextInfo:) context: nil];
    terminatedByUser = NO;
    // Warning: long running constructor. performs synchronous rsync. probably not good.
	rsyncTask = [[RsyncTask alloc] initWithSource:source destination:destination];
	rsyncTask.delegate = self;
    
    [(NSProgressIndicator*) [progressDialog accessoryView] setIndeterminate: NO]; 

	[rsyncTask sync];
};

#pragma mark -
#pragma mark RsyncTask Delegate Methods

- (void)rsyncTaskDidFinish: (RsyncTask *)task; {
	NSLog(@"did finish syncing");
    NSAlert * ack = [self acknowledgeDialogWithMessage: @"Library synchronized"
                                     informationalText: @"Have a nice day."
                                                 style: NSInformationalAlertStyle
                                                  icon: [self syncIcon]];
    [self showSheet: ack didEndSelector: @selector(userDidAcknowledge:returnCode:contextInfo:) context: nil];

	[delegate rsync:self didFinishSyncingSuccesful: YES];
}

- (void)rsyncTask: (RsyncTask *)task didFailWithError: (NSString *)error {
    if ( ! terminatedByUser) {
        NSLog(@"sync error: %@", error);
        NSAlert * ack = [self acknowledgeDialogWithMessage: @"Synchronization failed"
                                         informationalText: error
                                                     style: NSWarningAlertStyle
                                                      icon: [NSImage imageNamed: NSImageNameCaution]];
        [self showSheet: ack didEndSelector: @selector(userDidAcknowledge:returnCode:contextInfo:) context: nil];
    }
	[delegate rsync:self didFinishSyncingSuccesful: NO];
}

- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)progress {
    if ([currentSheet accessoryView] != nil) {
        NSProgressIndicator * progressBar = (NSProgressIndicator*)[currentSheet accessoryView];
        [progressBar setIndeterminate: NO];
        [progressBar setDoubleValue: progress];
    }
}

- (void)rsyncTask: (RsyncTask *)task didUpdateStatusMessage: (NSString *)message {
	if ([currentSheet accessoryView] != nil) {
        [currentSheet setInformativeText: [NSString stringWithFormat: @"%0.1f%% %@", [rsyncTask currentProgressPercent], message]];
    }
}  

#pragma mark -
#pragma mark Private Methods

-(void) userDidConfirmInitialSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        NSArray * srcDst = (NSArray*) contextInfo;
        [self performSync: [srcDst objectAtIndex: 0] destination: [srcDst objectAtIndex: 1]];
    }
}

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        NSAlert * confirm = [self confirmDialogWithMessage: @"Abort synchronization?" 
                                         informationalText: @"Aborting sync may lead to an inconsistent library." 
                                                     style: NSWarningAlertStyle icon: [NSImage imageNamed: NSImageNameCaution]];
        [self showSheet: confirm didEndSelector: @selector(userDidConfirmAbort:returnCode:contextInfo:) context: nil];
    }
}

-(void) userDidConfirmAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [rsyncTask terminate];
        terminatedByUser = YES;
    } else {
        NSAlert * progress = [self progressDialog];
        NSProgressIndicator * progressBar = (NSProgressIndicator*) [progress accessoryView];
        [progressBar setDoubleValue: [rsyncTask currentProgressPercent]];
        [self showSheet: [self progressDialog] didEndSelector: @selector(userDidAbortSync:returnCode:contextInfo:) context: nil];
    }
}

-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [self showSheet: nil didEndSelector: nil context: nil];
}

-(NSImage*) syncIcon {
    if (ourSyncIcon == nil) {
        ourSyncIcon = [NSImage imageNamed: @"icn_sync.icns"];
    }
    return ourSyncIcon;
}

-(void)showSheet: (NSAlert*) sheet didEndSelector: (SEL)theEndSelector context: (void*) context {
    if (currentSheet != nil) {
        [[currentSheet window] orderOut: self];
        [NSApp endSheet:[currentSheet window]];
    }
    if (sheet != nil) {
        [sheet beginSheetModalForWindow: documentWindow modalDelegate:self didEndSelector: theEndSelector contextInfo:context];
    } else {
    }
    currentSheet = sheet;
}

-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                               style: (NSAlertStyle) style icon: (NSImage*) icon
{
    NSAlert * dialog = [[[NSAlert alloc] init] autorelease];
    [dialog addButtonWithTitle:@"OK"];
    [dialog addButtonWithTitle:@"Cancel"];
    [dialog setMessageText: NSLocalizedString(message, nil)];
    [dialog setInformativeText: NSLocalizedString(informationalText, nil)];
    if (icon != nil) {
        [dialog setIcon: icon];
    }
    [dialog setAlertStyle: style];
    return dialog;
}

-(NSAlert*) acknowledgeDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                                   style: (NSAlertStyle) style icon: (NSImage*) icon
{
    NSAlert * dialog = [[[NSAlert alloc] init] autorelease];
    [dialog addButtonWithTitle:@"OK"];
    [dialog setMessageText: NSLocalizedString(message, nil)];
    [dialog setInformativeText: NSLocalizedString(informationalText, nil)];
    if (icon != nil) {
        [dialog setIcon: icon];
    }
    [dialog setAlertStyle: style];
    return dialog;    
}

-(NSAlert*) progressDialog {
    NSAlert * dialog = [[[NSAlert alloc] init] autorelease];
    [dialog addButtonWithTitle:@"Cancel"];
    [dialog setMessageText: NSLocalizedString(@"Synchronizing Library",nil)];
    [dialog setInformativeText: NSLocalizedString(@"This may take a while.",nil)];
    [dialog setAlertStyle: NSWarningAlertStyle];
    [dialog setIcon: [self syncIcon]];
    
    NSProgressIndicator * progressBar = [[[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 300, 20)] autorelease];
    [progressBar setIndeterminate: YES];
    [progressBar startAnimation: self];
    [dialog setAccessoryView: progressBar];
    return dialog;
}

@end
