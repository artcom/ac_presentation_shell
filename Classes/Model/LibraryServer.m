//
//  LibraryServer.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "LibraryServer.h"


@implementation LibraryServer
@synthesize netService;

- (id) initWithNetService: (NSNetService*) aNetService {
    self = [super init];
    if (self != nil) {
        netService = [aNetService retain];
        [netService setDelegate: self];
        [self willChangeValueForKey: @"hostname"];
        [netService resolveWithTimeout: 10];
    }
    return self;
}

- (void) dealloc {
    [netService release];
    
    [super dealloc];
}

- (NSString*) hostname {
    return [netService hostName];
}

#pragma mark -
#pragma mark NSNetServiceDelegate Protocol Methods
- (void)netServiceDidResolveAddress: (NSNetService *) sender {
    NSLog(@"=== resolved %@", [sender hostName]);
    [self didChangeValueForKey: @"hostname"];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [self didChangeValueForKey: @"hostname"];
    NSLog(@"=== failed to resolve: %@", errorDict);
}


@end

