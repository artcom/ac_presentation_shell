//
//  LibraryServer.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "LibraryServer.h"


@implementation LibraryServer

@synthesize hostname;
@synthesize netService;
@synthesize title;

- (id) initWithNetService: (NSNetService*) aNetService {
    self = [super init];
    if (self != nil) {
        netService = [aNetService retain];
        [netService setDelegate: self];
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

- (NSString*) title {
    return [NSString stringWithString: @"narf"];
}

#pragma mark -
#pragma mark NSNetServiceDelegate Protocol Methods
- (void)netServiceDidResolveAddress: (NSNetService *) sender {
    [self willChangeValueForKey: @"hostname"];
    [self didChangeValueForKey: @"hostname"];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"=== failed to resolve: %@", errorDict);
}


@end

