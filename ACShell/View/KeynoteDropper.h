//
//  KeynoteDropper.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KeynoteDropperDelegate;
@interface KeynoteDropper : NSImageView
@property (nonatomic, weak) IBOutlet id<KeynoteDropperDelegate> delegate;
@property (nonatomic, strong) NSString *filename;
@property (readonly) BOOL fileExists;

@end

@protocol KeynoteDropperDelegate
- (void) userDidDropKeynote: (KeynoteDropper *)keynoteDraglet;
- (void) userDidDoubleClickKeynote: (KeynoteDropper *)keynoteDraglet;
@end
