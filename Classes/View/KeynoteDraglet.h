//
//  KeynoteDraglet.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IconDraglet.h"

@protocol KeynoteDragletDelegate;
@interface KeynoteDraglet : IconDraglet
@property (nonatomic, weak) IBOutlet id<KeynoteDragletDelegate> delegate;
@property (readonly) BOOL fileExists;
@end

@protocol KeynoteDragletDelegate
- (void) userDidDropKeynote: (KeynoteDraglet *)keynoteDraglet;
- (void) userDidDoubleClickKeynote: (KeynoteDraglet *)keynoteDraglet;
@end
