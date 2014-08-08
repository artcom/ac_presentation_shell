//
//  NSImageViewWithDroppedFilename.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImageViewWithDroppedFilename : NSImageView

@property (nonatomic, strong) NSString * filename;
@property (readonly) BOOL fileExists;

@end
