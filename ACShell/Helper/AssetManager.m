//
//  AssetImport.m
//  ACShell
//
//  Created by David Siegel on 8/8/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "AssetManager.h"
#import "Presentation.h"
#import "localized_text_keys.h"

static void fileOpStatusCallback (FSFileOperationRef fileOp,
                                  const FSRef *currentItem,
                                  FSFileOperationStage stage,
                                  OSStatus error,
                                  CFDictionaryRef statusDictionary,
                                  void *info );

static NSNumber * copy_op;
static NSNumber * trash_op;

@interface AssetManager ()
- (void) performNextOperation;
- (void) fileOp:(FSFileOperationRef) fileOp didUpdateStatus:(const FSRef*)currentItem
          stage:(FSFileOperationStage)stage error:(OSStatus)error
         status:(CFDictionaryRef)statusDictionary;
@end

@implementation AssetManager

+ (void) initialize {
    copy_op = [NSNumber numberWithInt: 1];
    trash_op = [NSNumber numberWithInt: 2];
}

- (id) initWithPresentation:(Presentation*)thePresentation
           progressDelegate:(id<ProgressDelegateProtocol>)theProgressDelegate
            libraryDelegate:(id<LibraryDelegateProtocol>)theLibraryDelegate
{
    self = [super init];
    if (self != nil) {
        self.presentation = thePresentation;
        self.progressDelegate = theProgressDelegate;
        self.libraryDelegate = theLibraryDelegate;
        self.assets = NSMutableArray.new;
        self.index = 0;
    }
    return self;
}


- (void) copyAsset: (NSString*) assetPath {
    [self.assets addObject: [NSArray arrayWithObjects: copy_op, assetPath, nil]];
}

- (void) trashAsset: (NSString*) assetPath {
    [self.assets addObject: [NSArray arrayWithObjects: trash_op, assetPath, nil]];
}

- (void) run {
    [self performNextOperation];
}

- (void) performNextOperation {
    if (self.index == [self.assets count]) {
        [self.progressDelegate operationDidFinish];
        [self.libraryDelegate operationDidFinish];
        return;
    }
    NSArray * operation = [self.assets objectAtIndex:self.index++];
    NSNumber * opcode = [operation objectAtIndex: 0];
    NSString * src = [operation objectAtIndex: 1];
    
    FSRef srcRef;
    FSPathMakeRef((UInt8*)[src fileSystemRepresentation], &srcRef, NULL);
    Boolean isDir = TRUE;
    FSRef destDirRef;
    FSPathMakeRef((UInt8*)self.presentation.absoluteDirectory.fileSystemRepresentation, &destDirRef, &isDir);
    
    FSFileOperationRef op = FSFileOperationCreate(NULL);
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    OSStatus error = FSFileOperationScheduleWithRunLoop(op, runLoop, kCFRunLoopDefaultMode);
    if (error != noErr) {
        NSLog(@"Error: failed to schedule file op on run loop");
        return;
    }
    
    FSFileOperationClientContext	clientContext;
    
    clientContext.version = 0;
    clientContext.info = (__bridge void *) self;
    clientContext.retain = CFRetain;
    clientContext.release = CFRelease;
    clientContext.copyDescription = NULL;
    
    if ([opcode isEqualToNumber: copy_op]) {
        error = FSCopyObjectAsync(op, &srcRef, &destDirRef, NULL, kFSFileOperationDefaultOptions, fileOpStatusCallback, 1.0, &clientContext);
        [self.progressDelegate setMessage:NSLocalizedString(ACSHELL_STR_COPYING_ITEMS, nil)];
        if (error != noErr) {
            NSLog(@"Error: failed to copy assets: %d", (int)error);
        }
    } else if ([opcode isEqualToNumber: trash_op]) {
        [self.progressDelegate setMessage:NSLocalizedString(ACSHELL_STR_TRASHING_ITEMS, nil)];
        error = FSMoveObjectToTrashAsync(op, &srcRef, kFSFileOperationDefaultOptions, fileOpStatusCallback, 1.0, &clientContext);
        if (error != noErr) {
            NSLog(@"Error: failed to delete assets: %d", (int)error);
        }
    }
}

- (void) fileOp:(FSFileOperationRef)fileOp didUpdateStatus:(const FSRef*)currentItem
          stage:(FSFileOperationStage)stage error:(OSStatus)error
         status:(CFDictionaryRef)status
{
    if (error) {
        NSError *e = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
        [self.progressDelegate operationDidFinishWithError:e];
        [self.libraryDelegate operationDidFinishWithError:e];
        return;
    }
    
    if (status) {
        NSNumber *itemsCompleted = (NSNumber*) CFDictionaryGetValue(status, kFSOperationObjectsCompleteKey);
        NSNumber *bytesCompleted = (NSNumber*) CFDictionaryGetValue(status, kFSOperationBytesCompleteKey);
        NSNumber *totalItems = (NSNumber*) CFDictionaryGetValue(status, kFSOperationTotalObjectsKey);
        NSNumber *totalBytes = (NSNumber*) CFDictionaryGetValue(status, kFSOperationTotalBytesKey);
        if (itemsCompleted && bytesCompleted && totalItems && totalBytes) {
            double percent = ([bytesCompleted doubleValue] / [totalBytes doubleValue]) * 100;
            NSString *text = [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_OF_WITH_PERCENT, nil),
                              itemsCompleted.intValue + 1, totalItems.intValue, percent];
            [self.progressDelegate setProgress:percent text:text];
        }
    }
    
    if (stage == kFSOperationStageComplete) {
        [self performNextOperation];
    }
}
@end

static void fileOpStatusCallback(FSFileOperationRef fileOp,
                                 const FSRef *currentItem,
                                 FSFileOperationStage stage,
                                 OSStatus error,
                                 CFDictionaryRef status,
                                 void *info )
{
    AssetManager * importer = (__bridge AssetManager*) info;
    [importer fileOp:fileOp didUpdateStatus:currentItem stage:stage error:error status:status];
}
