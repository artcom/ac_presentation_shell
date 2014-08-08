//
//  KeynoteDropper.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSImageViewWithDroppedFilename.h"
#import "KeynoteDropper.h"

@interface KeynoteDropper : NSImageView {
    NSString * filename;
    
    BOOL fileExists;
}

@property (nonatomic, strong) NSString * filename;
@property (readonly) BOOL fileExists;

@end
