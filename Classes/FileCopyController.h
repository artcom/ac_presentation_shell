//
//  FileCopyController.h
//  ACShell
//
//  Created by Robert Palmer on 26.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FileCopyController;

@protocol FileCopyControllerDelegate <NSObject>

- (void)fileCopyControllerDidFinish: (FileCopyController *)controller;
- (void)fileCopyControllerDidFail: (FileCopyController *)controller;

@end



@interface FileCopyController : NSObject {
	NSWindow *window;
	NSAlert *progressSheet;
	
	BOOL isCopying;
	id <FileCopyControllerDelegate> delegate;
}

@property (assign) id <FileCopyControllerDelegate> delegate;
@property (assign) BOOL isCopying;

- (id)initWithParentWindow: (NSWindow *)aWindow;
- (void)copy: (NSString *)source to: (NSString *)destination;

- (void)didFinishCopying: (NSNotification *)notification;

@end
