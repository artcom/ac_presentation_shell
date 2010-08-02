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
@synthesize name;
@synthesize administratorAddress;

- (id) initWithNetService: (NSNetService*) aNetService {
    self = [super init];
    if (self != nil) {
        netService = [aNetService retain];
        [netService setDelegate: self];
        [netService resolveWithTimeout: 10];
        txtRecord = nil;
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

- (NSString*) name {
    NSData * value = [txtRecord objectForKey: @"name"];
    if (value != nil) {
        return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
    }
    return [NSString stringWithString: @""];
}

- (NSString*) administratorAddress {
    NSData * value = [txtRecord objectForKey: @"administrator"];
    if (value != nil) {
        return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
    }
    return [NSString stringWithString: @""];
}

#pragma mark -
#pragma mark NSNetServiceDelegate Protocol Methods
- (void)netServiceDidResolveAddress: (NSNetService *) sender {
    NSData * txtRecordData = [netService TXTRecordData];
    if (txtRecordData != nil) {
        txtRecord = [[NSNetService dictionaryFromTXTRecordData: txtRecordData] retain];
    }
    
    // XXX stupid ...but works
    [self willChangeValueForKey: @"hostname"];
    [self didChangeValueForKey: @"hostname"];
    

    [self willChangeValueForKey: @"name"];
    [self didChangeValueForKey: @"name"];    

    [self willChangeValueForKey: @"administratorAddress"];
    [self didChangeValueForKey: @"administratorAddress"];    
    
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"=== failed to resolve: %@", errorDict);
}


@end

