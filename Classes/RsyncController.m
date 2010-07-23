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
-(void) setFileProgress: (double) percent;

-(NSAlert*) progressDialog;
-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                               style: (NSAlertStyle) style icon: (NSImage*) icon buttonTitles: (NSArray *)titles;
-(NSAlert*) acknowledgeDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText style: (NSAlertStyle) style icon: (NSImage*) icon;
-(void)showSheet: (NSAlert*) sheet didEndSelector: (SEL)theEndSelector context: (void*) context;


@end

static NSImage * ourSyncIcon = nil;

@implementation RsyncController
@synthesize delegate;
@synthesize documentWindow;

@synthesize progressView;
@synthesize fileProgressBar;
@synthesize fileProgressLabel;
@synthesize totalProgressBar;
@synthesize totalProgressLabel;


- (id) init {
    self = [super init];
    if (self != nil) {
        [NSBundle loadNibNamed: @"RsyncProgressView" owner: self];
    }
    return self;   
}

-(void) awakeFromNib {
}

-(void) dealloc {
    [lastRsyncMessage release];
    
    [super dealloc];
}

- (void) syncWithSource: (NSString*) source destination: (NSString*) destination {
    [self performSync: source destination: destination];
}

-(void) initialSyncWithSource: (NSString*) source destination: (NSString*) destination {
    NSAlert * confirm = [self confirmDialogWithMessage: @"Synchronize library now?"
                                     informationalText: @"A good network connection and some patience is required."
                                                 style: NSInformationalAlertStyle
                                                  icon: [self syncIcon] 
												buttonTitles: nil];
    NSArray * srcDst = [[NSArray arrayWithObjects: source, destination, nil] retain];
    [self showSheet: confirm didEndSelector: @selector(userDidConfirmInitialSync:returnCode:contextInfo:) context: srcDst];
}

-(void) performSync: (NSString*) source destination: (NSString*) destination {
    NSAlert * progressDialog = [self progressDialog];
    [self showSheet: progressDialog didEndSelector: @selector(userDidAbortSync:returnCode:contextInfo:) context: nil];
    terminatedByUser = NO;
	rsyncTask = [[RsyncTask alloc] initWithSource:source destination:destination];
	rsyncTask.delegate = self;
    
    fileProgressLabel.stringValue = [NSString stringWithFormat: @"%3.1f%%", 0.0];
    totalProgressLabel.stringValue = @"";

	[rsyncTask sync];
};

-(void) setFileProgress: (double) percent {
    fileProgressBar.doubleValue = percent;
    fileProgressLabel.stringValue = [NSString stringWithFormat: @"%3.1f%%", percent];
}

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

- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)fileProgress
       itemNumber: (NSInteger) itemNumber of: (NSInteger) itemCount
{
    [self setFileProgress: fileProgress];
    
    if (itemNumber >= 0 && itemCount >= 0) {
        double totalPercent = ((double)itemNumber / itemCount) * 100;
        totalProgressBar.doubleValue = totalPercent;
        totalProgressLabel.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Checked %d of %d files (%3.1f%%)", nil),
                                          itemNumber, itemCount, totalPercent];
    } else if (itemCount >= 0) {
        totalProgressLabel.stringValue = [NSString stringWithFormat: NSLocalizedString(@"Checking %d files", nil), itemCount];
    }
}

- (void)rsyncTask: (RsyncTask *)task didUpdateMessage: (NSString *)message {    
	if ([currentSheet accessoryView] == progressView) {        
        [currentSheet setInformativeText: message];
    }
    
    [fileProgressBar setIndeterminate: NO];
    [totalProgressBar setIndeterminate: NO];
    
    [lastRsyncMessage release];
    lastRsyncMessage = [message retain];
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
                                                     style: NSWarningAlertStyle icon: [NSImage imageNamed: NSImageNameCaution] 
											  buttonTitles: [NSArray arrayWithObjects:@"Abort", @"Continue syncing", nil]];
        [self showSheet: confirm didEndSelector: @selector(userDidConfirmAbort:returnCode:contextInfo:) context: nil];
    }
}

-(void) userDidConfirmAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [rsyncTask terminate];
        terminatedByUser = YES;
    } else if (returnCode == NSAlertSecondButtonReturn) {
        NSAlert * progress = [self progressDialog];
        [progress setInformativeText: lastRsyncMessage];
        [self showSheet: [self progressDialog] didEndSelector: @selector(userDidAbortSync:returnCode:contextInfo:) context: nil];
        [fileProgressBar setIndeterminate: NO];
        [totalProgressBar setIndeterminate: NO];
        
    }
}

-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
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
		[currentSheet release];
		currentSheet = nil;
    }
    if (sheet != nil) {
        [sheet beginSheetModalForWindow: documentWindow modalDelegate:self didEndSelector: theEndSelector contextInfo:context];
    } 
	
	currentSheet = [sheet retain];
}

-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                               style: (NSAlertStyle) style icon: (NSImage*) icon buttonTitles: (NSArray *)titles
{
    NSAlert * dialog = [[[NSAlert alloc] init] autorelease];

	if (titles == nil) {
		titles = [NSArray arrayWithObjects:@"OK", @"Cancel", nil];
	}

	for (NSString *title in titles) {
		[dialog addButtonWithTitle: NSLocalizedString(title, nil)];
	}

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
    [dialog addButtonWithTitle:@"Abort"];
    [dialog setMessageText: NSLocalizedString(@"Synchronizing Library",nil)];
    [dialog setInformativeText: NSLocalizedString(@"This may take a while.",nil)];
    [dialog setAlertStyle: NSWarningAlertStyle];
    [dialog setIcon: [self syncIcon]];
    
    [dialog setAccessoryView: progressView];
    
    [fileProgressBar setIndeterminate: YES];
    [fileProgressBar startAnimation: self];

    [totalProgressBar setIndeterminate: YES];
    [totalProgressBar startAnimation: self];
    return dialog;
}

@end
