//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationDataContext.h"

@class Presentation;
@class ACShellController;

@interface EditWindowController : NSWindowController <PresentationDataContext> {
    Presentation * editPresentation;
    Presentation * originalPresentation;
    
    NSXMLElement * editNode;
    ACShellController * shellController;
    
    NSString * thumbnailFilename;
}

@property (retain) Presentation * editPresentation;


- (id) initWithShellController:(ACShellController *)theShellController;

- (IBAction) userDidConfirmEdit: (id) sender;
- (IBAction) userDidCancelEdit: (id) sender;
- (IBAction) userDidDropImage: (id) sender;

- (void) edit: (Presentation*) aPresentation;


@end
