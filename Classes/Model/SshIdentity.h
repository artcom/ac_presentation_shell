//
//  SshIdentity.h
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SshIdentityFile : NSObject {
    NSString * path;
}

@property (retain) NSString * path;
@property (readonly) NSString * filename;


- (id) initWithPath: (NSString*) path;

@end
