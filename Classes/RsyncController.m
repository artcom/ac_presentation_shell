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
-(void) userDidAcknowledgeAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(NSImage*) syncIcon;
-(void) setupAlert: (id) windowOrAlert;

@end

static NSImage * ourSyncIcon = nil;

@implementation RsyncController
@synthesize delegate;

- (id) initWithSource: (NSString*) sourceDir destination: (NSString*) destinationDir {
    self = [super init];
    if (self != nil) {
        source = [sourceDir retain];
        destination = [destinationDir retain];
        targetLibrarySize = 0;
    }
    return self;   
}

-(void) dealloc {
    [source release];
    [destination release];
    
    [super dealloc];
}

- (void) sync: (NSWindow*) window {
	rsyncTask = [[RsyncTask alloc] initWithSource:source desctination:destination];
	rsyncTask.delegate = self;
	[rsyncTask sync];
    
	[self setupAlert: window];
   	[(NSProgressIndicator*)[alert accessoryView] setIndeterminate: NO]; 
};

-(void) setupAlert: (NSWindow*) window {
    sheetOwningWindow = [window retain];
    alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText: NSLocalizedString(@"Synchronizing Library",nil)];
    [alert setInformativeText: NSLocalizedString(@"This may take a while.",nil)];
    [alert setAlertStyle: NSWarningAlertStyle];
    [alert setIcon: [self syncIcon]];
    
    NSProgressIndicator * progressBar = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 300, 20)];
    [progressBar setIndeterminate: YES];
    [progressBar startAnimation: self];
    [alert setAccessoryView: progressBar];
    [alert beginSheetModalForWindow: window modalDelegate: self
                     didEndSelector:@selector(userDidAbortSync:returnCode:contextInfo:) contextInfo:nil];
}

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {	
	[[alert window] orderOut:self];
	[rsyncTask terminate];
}

-(void) userDidAcknowledgeAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheetOwningWindow release];
	sheetOwningWindow = nil;
}

-(NSImage*) syncIcon {
    if (ourSyncIcon == nil) {
        ourSyncIcon = [NSImage imageNamed: @"icn_sync.icns"];
    }
    return ourSyncIcon;
}

- (void)showResultDialog {
	NSAlert *ackAlert = [[NSAlert alloc] init];
	[ackAlert addButtonWithTitle:@"OK"];
	[ackAlert setAlertStyle: NSWarningAlertStyle];
	[ackAlert setIcon: [NSImage imageNamed: NSImageNameCaution]];
	[ackAlert setMessageText: NSLocalizedString(@"Synchronization aborted.",nil)];
	[ackAlert setInformativeText: NSLocalizedString(@"Library might be in an inconsistent state.", nil)];
	
	[ackAlert beginSheetModalForWindow: sheetOwningWindow modalDelegate: self
						didEndSelector:@selector(userDidAcknowledgeAbort:returnCode:contextInfo:) contextInfo:nil];	
}


#pragma mark -
#pragma mark RsyncTask Delegate Methods

- (void)rsyncTaskDidFinish: (RsyncTask *)task; {
	NSLog(@"did finish syncing");
	
	if ([[alert window] isVisible]) {
		[NSApp endSheet:[alert window]];
	}
	
	[delegate rsync:self didFinishSyncingSuccesful: YES];
	alert = nil;
}

- (void)rsyncTask: (RsyncTask *)task didFailWithError: (NSString *)error {
	NSLog(@"sync error: %@", error);
	if ([[alert window] isVisible]) {
		[NSApp endSheet:[alert window]];
	}
	alert = nil;

	[self showResultDialog];
	[delegate rsync:self didFinishSyncingSuccesful: YES];
}

- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)progress {
	NSProgressIndicator * progressBar = (NSProgressIndicator*) [alert accessoryView];
	[progressBar setDoubleValue: progress];
}

- (void)rsyncTask: (RsyncTask *)task didUpdateStatusMessage: (NSString *)message {
	[alert setInformativeText: message];
}  

@end
