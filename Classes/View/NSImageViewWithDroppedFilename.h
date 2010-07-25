//
//  NSImageViewWithDroppedFilename.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImageViewWithDroppedFilename : NSImageView {
    NSString * filename;
}

@property (readonly) NSString * filename;

@end
