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
- (void) fileOp: (FSFileOperationRef) fileOp didUpdateStatus: (const FSRef*) currentItem 
          stage: (FSFileOperationStage) stage error: (OSStatus) error 
statusDictionary: (CFDictionaryRef) statusDictionary;

@end

@implementation AssetManager

+ (void) initialize {
    copy_op = [NSNumber numberWithInt: 1];
    trash_op = [NSNumber numberWithInt: 2];
}

- (id) initWithPresentation: (Presentation*) thePresentation 
           progressDelegate: (id<ProgressDelegateProtocol>) theDelegate
{
    self = [super init];
    if (self != nil) {
        presentation = thePresentation;
        delegate = theDelegate;
        assets = [[NSMutableArray alloc] init];
        index = 0;
    }
    return self;
}


- (void) copyAsset: (NSString*) assetPath {
    [assets addObject: [NSArray arrayWithObjects: copy_op, assetPath, nil]];
}

- (void) trashAsset: (NSString*) assetPath {
    [assets addObject: [NSArray arrayWithObjects: trash_op, assetPath, nil]];
}

- (void) run {
    [self performNextOperation];
}

- (void) performNextOperation {
    if (index == [assets count]) {
        [delegate operationDidFinish];
        return;
    }
    NSArray * operation = [assets objectAtIndex: index++];
    NSNumber * opcode = [operation objectAtIndex: 0];
    NSString * src = [operation objectAtIndex: 1];
    
    FSRef srcRef;
    FSPathMakeRef((UInt8*)[src fileSystemRepresentation], &srcRef, NULL);
    Boolean isDir = TRUE;
    FSRef destDirRef;
    FSPathMakeRef((UInt8*)[[presentation absoluteDirectory] fileSystemRepresentation], &destDirRef, &isDir);

    FSFileOperationRef op = FSFileOperationCreate(NULL);
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    OSStatus error = FSFileOperationScheduleWithRunLoop(op, runLoop, kCFRunLoopDefaultMode);
    if (error != noErr) {
        NSLog(@"Broken: failed to schedule file op on run loop");
        return;
    }
    
    FSFileOperationClientContext	clientContext;

    clientContext.version = 0;
    clientContext.info = (__bridge void *) self;
    clientContext.retain = CFRetain;
    clientContext.release = CFRelease;
    clientContext.copyDescription = NULL;
    
    if ([opcode isEqualToNumber: copy_op]) {
        error = FSCopyObjectAsync(op, &srcRef, &destDirRef, NULL, kFSFileOperationDefaultOptions,
                                  fileOpStatusCallback, 1.0, &clientContext);
        [delegate setMessage: NSLocalizedString(ACSHELL_STR_COPYING_ITEMS, nil)];
    } else if ([opcode isEqualToNumber: trash_op]) {
        [delegate setMessage: NSLocalizedString(ACSHELL_STR_TRASHING_ITEMS, nil)];
        error = FSMoveObjectToTrashAsync(op, &srcRef, kFSFileOperationDefaultOptions,
                                         fileOpStatusCallback, 1.0, &clientContext);
    }	
}

- (void) fileOp: (FSFileOperationRef) fileOp didUpdateStatus: (const FSRef*) currentItem 
          stage: (FSFileOperationStage) stage error: (OSStatus) error 
statusDictionary: (CFDictionaryRef) statusDictionary
{
#pragma mark TODO: error handling!
    if (statusDictionary) {
        NSNumber *itemsCompleted, *bytesCompleted, *totalItems, *totalBytes;
        
        itemsCompleted = (NSNumber*) CFDictionaryGetValue(statusDictionary, kFSOperationObjectsCompleteKey);
        bytesCompleted = (NSNumber*) CFDictionaryGetValue(statusDictionary, kFSOperationBytesCompleteKey);
        totalItems = (NSNumber*) CFDictionaryGetValue(statusDictionary, kFSOperationTotalObjectsKey);
        totalBytes = (NSNumber*) CFDictionaryGetValue(statusDictionary, kFSOperationTotalBytesKey);
        if (itemsCompleted && bytesCompleted && totalItems && totalBytes) {
            double percent = ([bytesCompleted doubleValue] / [totalBytes doubleValue]) * 100;
            [delegate setProgress: percent
                             text: [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_OF_WITH_PERCENT, nil), 
                                    [itemsCompleted intValue] + 1, [totalItems intValue], 
                                    percent]];
        }
    }
    
    if (stage == kFSOperationStageComplete) {
        [self performNextOperation];
    }
}


@end

static void fileOpStatusCallback (FSFileOperationRef fileOp,
                            const FSRef *currentItem,
                            FSFileOperationStage stage,
                            OSStatus error,
                            CFDictionaryRef statusDictionary,
                            void *info )
{
    AssetManager * importer = (__bridge AssetManager*) info;
    [importer fileOp: fileOp didUpdateStatus: currentItem stage: stage error: error statusDictionary: statusDictionary];
    
}
