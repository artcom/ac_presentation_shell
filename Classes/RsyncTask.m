//
//  RsyncTask.m
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "RsyncTask.h"
#import "default_keys.h"

#define RSYNC_EXECUTABLE @"/usr/bin/rsync"

@interface NSString (appendSlash) 
- (NSString*) stringByAppendingSlash;
@end
@implementation NSString (appendSlash)

- (NSString*) stringByAppendingSlash {
    if ([self characterAtIndex: [self length] - 1] == '/') {
        return self;
    }    
    return [[NSArray arrayWithObjects: self, @"", nil] componentsJoinedByString: @"/"];
}

@end


@interface RsyncTask ()

@property (strong) NSTask *task;
@property (strong) NSPipe *pipe;
@property (strong) NSPipe *errorPipe;
@property (copy) NSString *source;
@property (copy) NSString *destination;
@property (assign) BOOL preserveLocalChanges;
@property (assign) NSUInteger targetLibrarySize;

- (void) cleanup;
- (void) processRsyncOutput: (NSData*) output;

@end


@implementation RsyncTask

@synthesize delegate;

- (id)initWithSource: (NSString *)theSource destination: (NSString *)theDestination; {
    self = [super init];
    if (self != nil) {	
        self.source = [theSource stringByAppendingSlash];
        self.destination = [theDestination stringByAppendingSlash];
        self.preserveLocalChanges = [NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_RSYNC_PRESERVE_LOCAL];
    }
    
    return self;
}



- (void)sync {
    NSLog(@"syncing from %@ to %@", self.source, self.destination);
    
    self.task = NSTask.new;
    [self.task setLaunchPath: RSYNC_EXECUTABLE];
    
    NSString *deleteOrUpdate = nil;
    if (self.preserveLocalChanges) {
        deleteOrUpdate = @"--update";
    }
    else {
        deleteOrUpdate = @"--delete";
    }
    
    NSMutableArray *taskArgs = [NSMutableArray arrayWithObjects: @"-rlt", @"--progress", @"--force",
                                deleteOrUpdate,
                                @"--chmod=u=rwX,go=rX",
                                @"-O",
                                self.source, self.destination, nil];
    
    [self.task setArguments: taskArgs];
    
    self.pipe = NSPipe.new;
    [self.task setStandardOutput:self.pipe];
    
    self.errorPipe = NSPipe.new;
    [self.task setStandardError:self.errorPipe];
    
    // required to make the askpass magic work
    [self.task setStandardInput: [NSFileHandle fileHandleWithNullDevice]];
    NSString * askpasswdPath = [[NSBundle mainBundle] pathForResource: @"acshell_askpasswd" ofType: @""];
    
    NSMutableDictionary * env = [[[NSProcessInfo processInfo] environment] mutableCopy];
    [env setObject: askpasswdPath forKey: @"SSH_ASKPASS"];
    [env setObject: @"NONE" forKey: @"DISPLAY"];
    NSURL *iconUrl = [[NSBundle mainBundle] URLForResource:@"dialog_app_icon" withExtension:@"png"];
    [env setObject:iconUrl forKey:@"ACSHELL_ICON_URL"];
    [self.task setEnvironment: env];
    
    [NSNotificationCenter.defaultCenter addObserver: self selector: @selector(rsyncDidUpdateProgress:)
                                               name: NSFileHandleReadCompletionNotification object:[self.pipe fileHandleForReading]];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didFinishRsync:)
                                               name:NSTaskDidTerminateNotification object:self.task];
    
    [[self.pipe fileHandleForReading] readInBackgroundAndNotify];
    [self.task launch];
}

- (void)terminate {
    [self.task terminate];
}

-(void) processRsyncOutput: (NSData*) output {
    NSString * str = [[NSString alloc] initWithData: output encoding:NSASCIIStringEncoding];
    NSArray * lines = [str componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString * line in lines) {
        if ([line length] == 0) {
            continue;
        }
        if ([line characterAtIndex: 0] == ' ') {
            NSScanner * scanner = [[NSScanner alloc] initWithString: line];
            [scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceCharacterSet]];
            NSInteger maybeFileCount = -1;
            if ( ! [scanner scanInteger: &maybeFileCount]) {
                continue;
            }
            double progress;
            if ( ! [scanner scanDouble: &progress]) {
                if (maybeFileCount >= 0) {
                    if ([delegate respondsToSelector:@selector(rsyncTask:didUpdateProgress:itemNumber:of:)]) {
                        [delegate rsyncTask: self didUpdateProgress: 0.0 itemNumber: -1 of: maybeFileCount];	
                    }                    
                }
                continue;
            }
            if ( ! [scanner scanUpToString:@"=" intoString:nil]) {
                NSLog(@"failed to parse rsync output: '='");
                continue;
            }
            NSInteger pendingItems = 0;
            [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"="]];
            if ( ! [scanner scanInteger: & pendingItems]) {
                pendingItems = -1;
            }
            [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSInteger totalItems = 0;
            if ( ! [scanner scanInteger: & totalItems]) {
                totalItems = -1;
            }
            
            if ([delegate respondsToSelector:@selector(rsyncTask:didUpdateProgress:itemNumber:of:)]) {
                [delegate rsyncTask: self didUpdateProgress: progress itemNumber: totalItems - pendingItems of: totalItems];	
            }
        } else {
            if ([delegate respondsToSelector:@selector(rsyncTask:didUpdateMessage:)]) {
                [delegate rsyncTask:self didUpdateMessage: line];
            }
        }
    }
    
}

-(void)rsyncDidUpdateProgress: (NSNotification*) notification {
    NSData * data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    if ([data length] == 0) {
        return;
    }
    
    [self processRsyncOutput: data];
    [[self.pipe fileHandleForReading] readInBackgroundAndNotify];
}

- (void)didFinishRsync: (NSNotification *)aNotification {	
    NSInteger terminationStatus = [self.task terminationStatus];
    
    if (terminationStatus == 0) {
        if ([delegate respondsToSelector:@selector(rsyncTaskDidFinish:)]) {
            [delegate rsyncTaskDidFinish:self];
        }
    } else {
        if ([delegate respondsToSelector:@selector(rsyncTask:didFailWithError:)]) {
            NSData *errorData = [[self.errorPipe fileHandleForReading] readDataToEndOfFile];
            [delegate rsyncTask:self didFailWithError: [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding]];
        }
    }
    
    [self cleanup];
}

- (void)cleanup {
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSTaskDidTerminateNotification object:self.task];
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSFileHandleReadCompletionNotification object:[self.pipe fileHandleForReading]];
    self.task = nil;
    self.pipe = nil;
}



@end
