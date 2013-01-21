//
//  PublicKeyDraglet.h
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PublicKeyDraglet : NSImageView {
    NSString * filename;
}

@property (nonatomic, retain) NSString * filename;

@end
