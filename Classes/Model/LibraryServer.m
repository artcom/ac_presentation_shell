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

- (NSString*) name {
    NSData * txtRecordData = [[netService TXTRecordData] retain];
    if (txtRecordData != nil) {
        NSDictionary * txtRecord = [NSNetService dictionaryFromTXTRecordData: txtRecordData];
        NSData * value = [txtRecord objectForKey: @"name"];
        if ( value != nil) {
            return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
        }
    }
    return [NSString stringWithString: @"Unknown"];
}

#pragma mark -
#pragma mark NSNetServiceDelegate Protocol Methods
- (void)netServiceDidResolveAddress: (NSNetService *) sender {
    [self willChangeValueForKey: @"hostname"];
    [self didChangeValueForKey: @"hostname"];
    
    // XXX stupid ...but works
    [self willChangeValueForKey: @"name"];
    [self didChangeValueForKey: @"name"];    

}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"=== failed to resolve: %@", errorDict);
}


@end

