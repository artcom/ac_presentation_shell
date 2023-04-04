//
//  FileDraglet.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageDraglet.h"

@interface FileDraglet : ImageDraglet
@property (readonly) BOOL fileExists;
@end
