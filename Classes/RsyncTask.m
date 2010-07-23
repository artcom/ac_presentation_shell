//
//  RsyncTask.m
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "RsyncTask.h"

#define RSYNC_EXECUTABLE @"/usr/bin/rsync"

@interface RsyncTask ()

- (NSUInteger) readTargetSizeFromRsyncOutput: (NSPipe *) outputPipe;
- (void) cleanup;
- (void) processRsyncOutput: (NSData*) output;
- (NSUInteger)dryRun;

@end


@implementation RsyncTask

@synthesize delegate;
@synthesize currentProgressPercent;

- (id)initWithSource: (NSString *)theSource destination: (NSString *)theDestination; {
	self = [super init];
	if (self != nil) {	
		source = [theSource retain];
		destination = [[theDestination stringByAppendingPathComponent:@""] retain];
		
		targetLibrarySize = [self dryRun];
	}
	
	return self;
}

- (void)dealloc {
	[pipe release];
	[errorPipe release];
	
	[source release];
	[destination release];
	
	[task release];
	
	[super dealloc];
}


- (void)sync {
    task = [[NSTask alloc] init];
    [task setLaunchPath: RSYNC_EXECUTABLE];
    [task setArguments: [NSArray arrayWithObjects:
                              @"-av", @"--progress", source, destination, nil]];
    pipe = [[NSPipe alloc] init];
    [task setStandardOutput: pipe];
	
	errorPipe = [[NSPipe alloc] init];
	[task setStandardError:errorPipe];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(rsyncDidUpdateProgress:)
                                                 name: NSFileHandleReadCompletionNotification object: [pipe fileHandleForReading]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishRsync:)
												 name:NSTaskDidTerminateNotification object:task];
	
	[[pipe fileHandleForReading] readInBackgroundAndNotify];
    [task launch];
}

- (NSUInteger)dryRun {
	NSTask * dryRunTask = [[[NSTask alloc] init] autorelease];
    [dryRunTask setLaunchPath: RSYNC_EXECUTABLE];
    [dryRunTask setArguments: [NSArray arrayWithObjects: 
							   @"-nav", source, destination, nil]];
    
	NSPipe * outPipe = [NSPipe pipe];
    [dryRunTask setStandardOutput: outPipe];
	
	NSPipe * dryErrorPipe = [NSPipe pipe];
	[dryRunTask setStandardError: dryErrorPipe];
	
    [dryRunTask launch];
    [dryRunTask waitUntilExit];
    if ([dryRunTask terminationStatus] != 0) {
        NSLog(@"rsync dry-run failed");
		NSData *errorData = [[dryErrorPipe fileHandleForReading] readDataToEndOfFile];
		[delegate rsyncTask:self didFailWithError: [[[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding] autorelease]];
        return 0;
    }
	
    return [self readTargetSizeFromRsyncOutput: outPipe];
}

- (void)terminate {
	[task terminate];
}


-(NSUInteger) readTargetSizeFromRsyncOutput: (NSPipe *) outputPipe {
    NSUInteger size = 0;
	
	NSString * output = [[NSString alloc] initWithData: [[outputPipe fileHandleForReading] readDataToEndOfFile] 
											  encoding:NSASCIIStringEncoding];
    
    NSArray * lines = [output componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    NSString * lastLine = [lines objectAtIndex: [lines count] - 2];
    NSScanner *theScanner = [NSScanner scannerWithString:lastLine];
	
    [theScanner scanUpToCharactersFromSet: [NSCharacterSet decimalDigitCharacterSet] intoString: nil];
    [theScanner scanInteger: (NSInteger*)& size];
	
	return size;
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
            currentProgressPercent = 100 * ((double)currentLibrarySize/targetLibrarySize);
			
			if ([delegate respondsToSelector:@selector(rsyncTask:didUpdateProgress:)]) {
				[delegate rsyncTask: self didUpdateProgress: currentProgressPercent];	
			}
		} else {
            if ([delegate respondsToSelector:@selector(rsyncTask:didUpdateStatusMessage:)]) {
				[delegate rsyncTask:self didUpdateStatusMessage: line];
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
    [[pipe fileHandleForReading] readInBackgroundAndNotify];
}

- (void)didFinishRsync: (NSNotification *)aNotification {	
	NSInteger terminationStatus = [task terminationStatus];
	
	if (terminationStatus == 0) {
		if ([delegate respondsToSelector:@selector(rsyncTaskDidFinish:)]) {
			[delegate rsyncTaskDidFinish:self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(rsyncTask:didFailWithError:)]) {
			NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
			[delegate rsyncTask:self didFailWithError: [[[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding] autorelease]];
		}
	}
	
	[self cleanup];
}

-(void) cleanup {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:task];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[pipe fileHandleForReading]];
	
	[task release];
	task = nil;
	[pipe release];
	pipe = nil;
}



@end
