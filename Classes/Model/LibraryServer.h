//
//  LibraryServer.h
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LibraryServer : NSObject <NSNetServiceDelegate> {
    NSNetService * netService;
    
    NSString * __weak hostname;
    NSString * __weak name;
    NSString * __weak administratorAddress;
    NSString * __weak rsyncSource;
    NSString * __weak rsyncPath;
    NSString * __weak readUser;
    NSString * __weak writeUser;
    NSString * __weak keyRequestEmailSubject;
    NSString * __weak keyRequestEmailBody;
    
    NSDictionary * txtRecord;
}

- (id) initWithNetService: (NSNetService*) aNetService;

@property (weak, readonly) NSString* hostname;
@property (weak, readonly) NSString* name;
@property (weak, readonly) NSString* administratorAddress;
@property (weak, readonly) NSString* rsyncSource;
@property (weak, readonly) NSString* rsyncPath;
@property (weak, readonly) NSString* readUser;
@property (weak, readonly) NSString* writeUser;
@property (weak, readonly) NSString* keyRequestEmailSubject;
@property (weak, readonly) NSString* keyRequestEmailBody;

@property (readonly) NSNetService * netService;

@end
