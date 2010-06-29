//
//  ACShellController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationWindowController;


@interface ACShellController : NSObject {
	NSArray *presentations;
	PresentationWindowController *presentationWindowController;
}

@property (retain, nonatomic) NSArray *presentations;

- (IBAction)play: (id)sender;
- (NSArray *)selectedPresentations;

@end
