//
//  LibraryServer.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "LibraryServer.h"
#import <netinet/in.h>
#import <arpa/inet.h>

@interface NSData (Additions)

- (int) port;
- (NSString*) host;
- (BOOL) isIPv4;
- (BOOL) isIPv6;

@end


@implementation NSData (Additions)

- (int) port {
    int port;
    struct sockaddr *addr;
    
    addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET)
        // IPv4 family
        port = ntohs(((struct sockaddr_in *)addr)->sin_port);
    else if(addr->sa_family == AF_INET6)
        // IPv6 family
        port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
    else
        // The family is neither IPv4 nor IPv6. Can't handle.
        port = 0;
    
    return port;
}


- (NSString *) host {
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET) {
        char *address = 
        inet_ntoa(((struct sockaddr_in *)addr)->sin_addr);
        if (address)
            return [NSString stringWithCString: address encoding: NSASCIIStringEncoding];
    }
    else if(addr->sa_family == AF_INET6) {
        struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
        char straddr[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(addr6->sin6_addr), straddr, 
                  sizeof(straddr));
        return [NSString stringWithCString: straddr encoding: NSASCIIStringEncoding];
    }
    return nil;
}

- (BOOL) isIPv4 {
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET) {
        return YES;
    }
    return NO;
}

- (BOOL) isIPv6 {
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET6) {
        return YES;
    }
    return NO;
}

@end


@implementation LibraryServer

@synthesize hostname;
@synthesize netService;
@synthesize name;
@synthesize administratorAddress;
@synthesize rsyncSource;
@synthesize rsyncPath;
@synthesize readUser;
@synthesize writeUser;

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
    return [netService name];
}

- (NSString*) rsyncPath {
    NSData * value = [txtRecord objectForKey: @"rsyncPath"];
    if (value != nil) {
        return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
    }
    return [NSString stringWithString: @""];
}

- (NSString*) rsyncSource {
    NSData * address = nil;
    for (NSData * adrData in [netService addresses]) {
        if ([adrData isIPv4]) {
            address = adrData;
            break;
        }
    }
    return [NSString stringWithFormat: @"%@:%@", [address host], self.rsyncPath];
}

- (NSString*) administratorAddress {
    NSData * value = [txtRecord objectForKey: @"administrator"];
    if (value != nil) {
        return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
    }
    return [NSString stringWithString: @""];
}

- (NSString*) readUser {
    NSData * value = [txtRecord objectForKey: @"readUser"];
    if (value != nil) {
        return [[[NSString alloc] initWithData: value encoding: NSUTF8StringEncoding] autorelease];
    }
    return [NSString stringWithString: @""];
}

- (NSString*) writeUser {
    NSData * value = [txtRecord objectForKey: @"writeUser"];
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
    
    [self willChangeValueForKey: @"rsyncPath"];
    [self didChangeValueForKey: @"rsyncPath"];
    
    [self willChangeValueForKey: @"rsyncSource"];
    [self didChangeValueForKey: @"rsyncSource"];        
    
    [self willChangeValueForKey: @"readUser"];
    [self didChangeValueForKey: @"readUser"];        
    
    [self willChangeValueForKey: @"writeUser"];
    [self didChangeValueForKey: @"writeUser"];        
    
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Failed to resolve: %@", errorDict);
}


@end

