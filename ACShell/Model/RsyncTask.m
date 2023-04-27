//
//  RsyncTask.m
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "RsyncTask.h"
#import "RsyncTaskDelegate.h"
#import "NSString+AppendSlash.h"
#import "default_keys.h"

#define RSYNC_EXECUTABLE @"/usr/bin/rsync"

@interface RsyncTask ()
@property (strong) NSTask *task;
@property (strong) NSPipe *outputPipe;
@property (strong) NSPipe *errorPipe;
@property (copy) NSString *source;
@property (copy) NSString *destination;
@property (assign) BOOL preserveLocalChanges;
@property (assign) NSUInteger targetLibrarySize;

- (void) cleanup;
- (void) processRsyncOutput: (NSData*) output;
@end


@implementation RsyncTask

- (id)initWithSource: (NSString *)theSource destination: (NSString *)theDestination {
    self = [super init];
    if (self != nil) {
        self.source = theSource.stringByAppendingSlash;
        self.destination = theDestination.stringByAppendingSlash;
        self.preserveLocalChanges = [NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_RSYNC_PRESERVE_LOCAL];
    }
    return self;
}

- (void)sync {
    NSLog(@"syncing from %@ to %@", self.source, self.destination);
    
    NSString *deleteOrUpdate = self.preserveLocalChanges ? @"--update" : @"--delete";
    NSArray *taskArgs = @[@"-rlt", @"--progress", @"--force",
                          deleteOrUpdate,
                          @"--chmod=u=rwX,go=rX",
                          @"-O",
                          self.source, self.destination];
    
    self.task = NSTask.new;
    self.task.launchPath = RSYNC_EXECUTABLE;
    self.task.arguments = taskArgs;
    
    self.outputPipe = NSPipe.new;
    self.task.standardOutput = self.outputPipe;
    
    self.errorPipe = NSPipe.new;
    self.task.standardError = self.errorPipe;
    
    // required to make the askpass magic work
    self.task.standardInput = NSFileHandle.fileHandleWithNullDevice;
    NSString * addhostkeyPath = [NSBundle.mainBundle pathForResource: @"acshell_addhostkey" ofType: @""];
    
    NSMutableDictionary *env = NSProcessInfo.processInfo.environment.mutableCopy;
    env[@"DISPLAY"] = @"NONE";
    env[@"SSH_ASKPASS"] = addhostkeyPath;
    env[@"ACSHELL_ICON_URL"] = [NSBundle.mainBundle URLForResource:@"dialog_app_icon" withExtension:@"png"];
    self.task.environment = env;
    
    [NSNotificationCenter.defaultCenter addObserver: self selector: @selector(rsyncDidUpdateProgress:)
                                               name: NSFileHandleReadCompletionNotification object:self.outputPipe.fileHandleForReading];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didFinishRsync:)
                                               name:NSTaskDidTerminateNotification object:self.task];
    
    [self.outputPipe.fileHandleForReading readInBackgroundAndNotify];
    [self.task launch];
}

- (void)terminate {
    [self.task terminate];
}

-(void) processRsyncOutput: (NSData*) output {
    NSString * str = [[NSString alloc] initWithData: output encoding:NSASCIIStringEncoding];
    NSArray * lines = [str componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
    for (NSString * line in lines) {
        if (line.length == 0) {
            continue;
        }
        if ([line characterAtIndex:0] == ' ') {
            NSScanner * scanner = [[NSScanner alloc] initWithString: line];
            scanner.charactersToBeSkipped = NSCharacterSet.whitespaceCharacterSet;
            
            NSInteger maybeFileCount = -1;
            if ( ! [scanner scanInteger: &maybeFileCount]) {
                continue;
            }
            double progress;
            if ( ! [scanner scanDouble: &progress]) {
                if (maybeFileCount >= 0) {
                    if ([self.delegate respondsToSelector:@selector(rsyncTask:didUpdateProgress:itemNumber:of:)]) {
                        [self.delegate rsyncTask: self didUpdateProgress: 0.0 itemNumber: -1 of: maybeFileCount];
                    }
                }
                continue;
            }
            if ( ! [scanner scanUpToString:@"=" intoString:nil]) {
                NSLog(@"failed to parse rsync output: '='");
                continue;
            }
            NSInteger pendingItems = 0;
            scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"="];
            if ( ! [scanner scanInteger: & pendingItems]) {
                pendingItems = -1;
            }
            scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"/"];
            NSInteger totalItems = 0;
            if ( ! [scanner scanInteger: & totalItems]) {
                totalItems = -1;
            }
            
            if ([self.delegate respondsToSelector:@selector(rsyncTask:didUpdateProgress:itemNumber:of:)]) {
                [self.delegate rsyncTask: self didUpdateProgress: progress itemNumber: totalItems - pendingItems of: totalItems];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(rsyncTask:didUpdateMessage:)]) {
                [self.delegate rsyncTask:self didUpdateMessage: line];
            }
        }
    }
    
}

-(void)rsyncDidUpdateProgress: (NSNotification*) notification {
    NSData * data = notification.userInfo[NSFileHandleNotificationDataItem];
    if (data.length == 0) {
        return;
    }
    
    [self processRsyncOutput: data];
    [self.outputPipe.fileHandleForReading readInBackgroundAndNotify];
}

- (void)didFinishRsync: (NSNotification *)aNotification {	
    NSInteger terminationStatus = self.task.terminationStatus;
    
    if (terminationStatus == 0) {
        if ([self.delegate respondsToSelector:@selector(rsyncTaskDidFinish:)]) {
            [self.delegate rsyncTaskDidFinish:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(rsyncTask:didFailWithError:)]) {
            NSData *errorData = [self.errorPipe.fileHandleForReading readDataToEndOfFile];
            [self.delegate rsyncTask:self didFailWithError: [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding]];
        }
    }
    [self cleanup];
}

- (void)cleanup {
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSTaskDidTerminateNotification object:self.task];
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSFileHandleReadCompletionNotification object:self.outputPipe.fileHandleForReading];
    self.task = nil;
    self.outputPipe = nil;
}

@end
