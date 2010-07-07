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
	NSMutableArray* categories;

	PresentationWindowController *presentationWindowController;
	
	NSArrayController *presentationsArrayController;
}

@property (retain, nonatomic) NSArray *presentations;
@property (retain, nonatomic) IBOutlet NSArrayController *presentationsArrayController;

- (IBAction)play: (id)sender;
- (NSArray *)selectedPresentations;

@end
