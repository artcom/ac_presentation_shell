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
    
    NSString * hostname;
    NSString * title;
}

- (id) initWithNetService: (NSNetService*) aNetService;

@property (readonly) NSString* hostname;
@property (readonly) NSString* title;
@property (readonly) NSNetService * netService;

@end
