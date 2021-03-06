//
//  SshIdentity.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "SshIdentity.h"


@implementation SshIdentityFile

- (id) initWithPath: (NSString*) aPath {
    self = [super init];
    if (self != nil) {
        self.path = aPath;
    }
    return self;
}


- (NSString*) filename {
    return [self.path lastPathComponent];
}

@end
