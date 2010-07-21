//
//  RsyncController.m
//  rsync_controller
//
//  Created by David Siegel on 7/20/10.
//  Copyright 2010 ART+COM. All rights reserved.
//

#import "RsyncController.h"

#define RSYNC_EXECUTABLE @"/usr/bin/rsync"
@interface RsyncController ()

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) userDidAcknowledgeAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(NSImage*) syncIcon;
-(void) setupAlert: (id) windowOrAlert;
-(void) readTargetSizeFromRsyncOutput: (NSPipe *) outputPipe;
-(void) processRsyncOutput: (NSData*) output;
-(void) cleanup;

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
    [self setupAlert: window];
    
    NSTask * dryRunTask = [[[NSTask alloc] init] autorelease];
    [dryRunTask setLaunchPath: RSYNC_EXECUTABLE];
    [dryRunTask setArguments: [NSArray arrayWithObjects: 
                              @"-nav", source, destination, nil]];
    NSPipe * dryRunPipe = [NSPipe pipe];
    [dryRunTask setStandardOutput: dryRunPipe];
    [dryRunTask launch];
    [dryRunTask waitUntilExit];
    if ([dryRunTask terminationStatus] != 0) {
        NSLog(@"rsync dry-run failed");
        // TODO: report dry run error
		[delegate rsync:self didFinishSyncingSuccesful:NO];
        return;
    }
    [self readTargetSizeFromRsyncOutput: dryRunPipe];
    
    [(NSProgressIndicator*)[alert accessoryView] setIndeterminate: NO];
    
    rsyncTask = [[NSTask alloc] init];
    [rsyncTask setLaunchPath: RSYNC_EXECUTABLE];
    [rsyncTask setArguments: [NSArray arrayWithObjects:
                              @"-av", @"--progress", source, destination, nil]];
    pipe = [[NSPipe alloc] init];
    [rsyncTask setStandardOutput: pipe];
    NSFileHandle * fileHandle = [pipe fileHandleForReading];

	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(rsyncDidUpdateProgress:)
                                                 name: NSFileHandleReadCompletionNotification object: fileHandle];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishRsync:)
												 name:NSTaskDidTerminateNotification object:rsyncTask];
	
	[fileHandle readInBackgroundAndNotify];
    [rsyncTask launch];
};

-(void) readTargetSizeFromRsyncOutput: (NSPipe *) outputPipe {
    NSString * output = [[NSString alloc] initWithData: [[outputPipe fileHandleForReading] readDataToEndOfFile] 
                                      encoding:NSASCIIStringEncoding];
    
    NSArray * lines = [output componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    NSString * lastLine = [lines objectAtIndex: [lines count] - 2];
    NSScanner *theScanner = [NSScanner scannerWithString:lastLine];

    [theScanner scanUpToCharactersFromSet: [NSCharacterSet decimalDigitCharacterSet] intoString: nil];
    [theScanner scanInteger: (NSInteger*)& targetLibrarySize];
}

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

-(void)rsyncDidUpdateProgress: (NSNotification*) notification {
    NSData * data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    if ([data length] == 0) {
        return;
    }
    [self processRsyncOutput: data];
    [[pipe fileHandleForReading] readInBackgroundAndNotify];
}

-(void) processRsyncOutput: (NSData*) output {
    NSArray * lines = [[[NSString alloc] initWithData: output encoding:NSASCIIStringEncoding] 
                       componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString * line in lines) {
        if ([line length] == 0) {
            continue;
        }
        NSScanner * scanner = [[NSScanner alloc] initWithString: line];
        [scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceCharacterSet]];
        NSUInteger currentLibrarySize;
        if ([scanner scanInteger: (NSInteger*) & currentLibrarySize]) {
            double progressPercent = 100 * ((double)currentLibrarySize/targetLibrarySize);
            NSProgressIndicator * progressBar = (NSProgressIndicator*) [alert accessoryView];
            [progressBar setDoubleValue: progressPercent];
        } else {
            NSString * msg = line;
            [alert setInformativeText: msg];
        }
    
    }
}

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {	
	[[alert window] orderOut:self];
	[rsyncTask terminate];
}

-(void) userDidAcknowledgeAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheetOwningWindow release];
	sheetOwningWindow = nil;
	
	NSLog(@"sync really aborted");
}

-(NSImage*) syncIcon {
    if (ourSyncIcon == nil) {
        ourSyncIcon = [NSImage imageNamed: @"icn_sync.icns"];
    }
    return ourSyncIcon;
}

-(void) cleanup {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:rsyncTask];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[pipe fileHandleForReading]];
	
	alert = nil;
	[rsyncTask release];
	rsyncTask = nil;
	[pipe release];
	pipe = nil;
}

- (void)didFinishRsync: (NSNotification *)aNotification {	
	NSLog(@"termination status: %d, running: %d", [rsyncTask terminationStatus], [rsyncTask isRunning]);
	NSInteger terminationStatus = [rsyncTask terminationStatus];
	
	if ([[alert window] isVisible]) {
		NSLog(@"closing window programmatically");
		[NSApp endSheet:[alert window]];
	}
	
	[self cleanup];
	
	if (terminationStatus != 0) {
		NSAlert *ackAlert = [[NSAlert alloc] init];
		[ackAlert addButtonWithTitle:@"OK"];
		[ackAlert setAlertStyle: NSWarningAlertStyle];
        [ackAlert setIcon: [NSImage imageNamed: NSImageNameCaution]];
		[ackAlert setMessageText: NSLocalizedString(@"Synchronization aborted.",nil)];
		[ackAlert setInformativeText: NSLocalizedString(@"Library might be in an inconsistent state.", nil)];
		
		[ackAlert beginSheetModalForWindow: sheetOwningWindow modalDelegate: self
							didEndSelector:@selector(userDidAcknowledgeAbort:returnCode:contextInfo:) contextInfo:nil];
	}
    [delegate rsync:self didFinishSyncingSuccesful: terminationStatus == 0];
}
/*
-(void)showSyncError: (NSString*) message title: (NSString*) title window
*/
@end
