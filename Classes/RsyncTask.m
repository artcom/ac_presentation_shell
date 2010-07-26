//
//  RsyncTask.m
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "RsyncTask.h"

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

- (void) cleanup;
- (void) processRsyncOutput: (NSData*) output;

@end


@implementation RsyncTask

@synthesize delegate;

- (id)initWithSource: (NSString *)theSource destination: (NSString *)theDestination; {
	self = [super init];
	if (self != nil) {	
		source = [[theSource stringByAppendingSlash] retain];
        destination = [[theDestination stringByAppendingSlash] retain];
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
                              @"-av", @"--progress", @"--delete", source, destination, nil]];
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

- (void)terminate {
	[task terminate];
}

-(void) processRsyncOutput: (NSData*) output {
    NSString * str = [[[NSString alloc] initWithData: output encoding:NSASCIIStringEncoding] autorelease];
    NSArray * lines = [str componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString * line in lines) {
        if ([line length] == 0) {
            continue;
        }
        if ([line characterAtIndex: 0] == ' ') {
            NSScanner * scanner = [[[NSScanner alloc] initWithString: line] autorelease];
            [scanner setCharactersToBeSkipped: [NSCharacterSet whitespaceCharacterSet]];
            NSInteger maybeFileCount = -1;
            if ( ! [scanner scanInteger: &maybeFileCount]) {
                NSLog(@"failed to parse rsync output: bytecount");
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
