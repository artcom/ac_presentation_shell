//
//  RsyncController.m
//  rsync_controller
//
//  Created by David Siegel on 7/20/10.
//  Copyright 2010 ART+COM. All rights reserved.
//

#import "RsyncController.h"
#import "RsyncTask.h"
#import "localized_text_keys.h"

@interface RsyncController ()

//-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
//-(void) userDidConfirmAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
//- (void)userDidConfirmInitialSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode srcDst:(NSArray *)srcDst;
//-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(NSImage*) syncIcon;
-(NSImage*) uploadIcon;
-(NSImage*) directionIcon;
-(void) performSync: (NSString*) source destination: (NSString*) destination;
-(void) setFileProgress: (double) percent;

-(NSAlert*) progressDialog;
-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                               style: (NSAlertStyle) style icon: (NSImage*) icon buttonTitles: (NSArray *)titles;
-(NSAlert*) acknowledgeDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText style: (NSAlertStyle) style icon: (NSImage*) icon;
//-(void)showSheet: (NSAlert*) sheet didEndSelector: (SEL)theEndSelector context: (void*) context;


@end

static NSImage * ourSyncIcon = nil;
static NSImage * ourUploadIcon = nil;

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


- (void) syncWithSource: (NSString*) source destination: (NSString*) destination {
    isUploading = NO;
    [self performSync: source destination: destination];
}

- (void)initialSyncWithSource:(NSString *)source destination:(NSString *)destination {
    isUploading = NO;
    NSAlert * confirm = [self confirmDialogWithMessage: ACSHELL_STR_SYNC_LIB_NOW
                                     informationalText: ACSHELL_STR_GOOD_CONNECTION
                                                 style: NSInformationalAlertStyle
                                                  icon: [self directionIcon] 
												buttonTitles: nil];

    [self showSheet:confirm completionHandler:^(NSModalResponse returnCode) {
        [self userDidConfirmInitialSync:confirm returnCode:returnCode source:source destination:destination];
    }];
}

- (void)uploadWithSource: (NSString*) source destination: (NSString*) destination {
    isUploading = YES;
    [self performSync: source destination: destination];
}

-(void) performSync: (NSString*) source destination: (NSString*) destination {
    
    NSAlert * progressDialog = [self progressDialog];
    [self showSheet:progressDialog completionHandler:^(NSModalResponse returnCode) {
        [self userDidAbortSync:progressDialog returnCode:returnCode contextInfo:nil];
    }];
    
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
    NSAlert *ack = [self acknowledgeDialogWithMessage: ACSHELL_STR_LIB_SYNCED
                                     informationalText: nil
                                                 style: NSInformationalAlertStyle
                                                  icon: [self directionIcon]];
    
    [self showSheet:ack completionHandler:^(NSModalResponse returnCode) {
        [self userDidAcknowledge:ack returnCode:returnCode contextInfo:nil];
    }];
    
	[delegate rsync:self didFinishSyncingSuccesful: YES];
}

- (void)rsyncTask: (RsyncTask *)task didFailWithError: (NSString *)error {
    if ( ! terminatedByUser) {
        NSLog(@"sync error: %@", error);
        const int maxLength = 6 * 80;
        if ([error length] > maxLength) {
            error = [error substringToIndex: maxLength];
        }
        NSAlert * ack = [self acknowledgeDialogWithMessage: ACSHELL_STR_SYNC_FAILED
                                         informationalText: error
                                                     style: NSWarningAlertStyle
                                                      icon: [NSImage imageNamed: NSImageNameCaution]];
        [self showSheet:ack completionHandler:^(NSModalResponse returnCode) {
            [self userDidAcknowledge:ack returnCode:returnCode contextInfo:nil];
        }];
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
        totalProgressLabel.stringValue = [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_CHECKED_N_OF_M_FILES, nil),
                                          itemNumber, itemCount, totalPercent];
    } else if (itemCount >= 0) {
        totalProgressLabel.stringValue = [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_CHECKING_N_FILES, nil), itemCount];
    }
}

- (void)rsyncTask: (RsyncTask *)task didUpdateMessage: (NSString *)message {    
	if ([currentSheet accessoryView] == progressView) {        
        [currentSheet setInformativeText: message];
    }
    
    [fileProgressBar setIndeterminate: NO];
    [totalProgressBar setIndeterminate: NO];
    
    lastRsyncMessage = message;
}  

#pragma mark -
#pragma mark Private Methods

- (void)userDidConfirmInitialSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode source:(NSString *)source destination:(NSString *)destination {
    if (returnCode == NSAlertFirstButtonReturn) {
        [self performSync:source destination:destination];
    }
}

-(void) userDidAbortSync:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        NSAlert * confirm = [self confirmDialogWithMessage: ACSHELL_STR_ABORT_SYNC 
                                         informationalText: ACSHELL_STR_ABORT_SYNC_WARNING 
                                                     style: NSWarningAlertStyle icon: [NSImage imageNamed: NSImageNameCaution] 
											  buttonTitles: [NSArray arrayWithObjects: ACSHELL_STR_ABORT, ACSHELL_STR_CONTINUE_SYNC, nil]];
        [self showSheet:confirm completionHandler:^(NSModalResponse returnCode) {
            [self userDidConfirmAbort:confirm returnCode:returnCode contextInfo:nil];
        }];
    }
}

-(void) userDidConfirmAbort:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [rsyncTask terminate];
        terminatedByUser = YES;
    } else if (returnCode == NSAlertSecondButtonReturn) {
        NSAlert * progress = [self progressDialog];
        [progress setInformativeText: lastRsyncMessage];
        [self showSheet:progress completionHandler:^(NSModalResponse returnCode) {
            [self userDidAbortSync:progress returnCode:returnCode contextInfo:nil];
        }];
        [fileProgressBar setIndeterminate: NO];
        [totalProgressBar setIndeterminate: NO];
        
    }
}

-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
}

-(NSImage*) syncIcon {
    if (ourSyncIcon == nil) {
        ourSyncIcon = [NSImage imageNamed: @"icn_sync"];
    }
    return ourSyncIcon;
}

-(NSImage*) uploadIcon {
    if (ourUploadIcon == nil) {
        ourUploadIcon = [NSImage imageNamed: @"icn_upload"];
    }
    return ourUploadIcon;
}

-(NSImage*) directionIcon {
    return isUploading ? [self uploadIcon] : [self syncIcon];
}

- (void)showSheet:(NSAlert *)sheet completionHandler:(void (^)(NSModalResponse returnCode))handler {
    if (currentSheet != nil) {
        [[currentSheet window] orderOut: self];
        [NSApp endSheet:[currentSheet window]];
		currentSheet = nil;
    }
    [sheet beginSheetModalForWindow:documentWindow completionHandler:handler];
    currentSheet = sheet;
}

//-(void)showSheet:(NSAlert *)sheet didEndSelector:(SEL)theEndSelector context:(void *)context {
//    if (currentSheet != nil) {
//        [[currentSheet window] orderOut: self];
//        [NSApp endSheet:[currentSheet window]];
//		currentSheet = nil;
//    }
//    if (sheet != nil) {
//        [sheet beginSheetModalForWindow: documentWindow modalDelegate:self didEndSelector: theEndSelector contextInfo:context];
//    } 
//	
//	currentSheet = sheet;
//}

-(NSAlert*) confirmDialogWithMessage: (NSString*) message informationalText: (NSString*) informationalText
                               style: (NSAlertStyle) style icon: (NSImage*) icon buttonTitles: (NSArray *)titles
{
    NSAlert * dialog = [[NSAlert alloc] init];

	if (titles == nil) {
		titles = [NSArray arrayWithObjects: ACSHELL_STR_OK, ACSHELL_STR_CANCEL, nil];
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
    NSAlert * dialog = [[NSAlert alloc] init];
    [dialog addButtonWithTitle: NSLocalizedString(ACSHELL_STR_OK, nil)];
    [dialog setMessageText: NSLocalizedString(message, nil)];
    [dialog setInformativeText: NSLocalizedString(informationalText, nil)];
    if (icon != nil) {
        [dialog setIcon: icon];
    }
    [dialog setAlertStyle: style];
    return dialog;    
}

-(NSAlert*) progressDialog {
    NSAlert * dialog = [[NSAlert alloc] init];
    [dialog addButtonWithTitle: NSLocalizedString(ACSHELL_STR_ABORT, nil)];
    [dialog setMessageText: NSLocalizedString(ACSHELL_STR_SYNCING,nil)];
    [dialog setInformativeText: NSLocalizedString(ACSHELL_STR_TAKE_A_WHILE,nil)];
    [dialog setAlertStyle: NSWarningAlertStyle];
    [dialog setIcon: [self directionIcon]];
    
    [dialog setAccessoryView: progressView];
    
    [fileProgressBar setIndeterminate: YES];
    [fileProgressBar startAnimation: self];

    [totalProgressBar setIndeterminate: YES];
    [totalProgressBar startAnimation: self];
    return dialog;
}

@end
