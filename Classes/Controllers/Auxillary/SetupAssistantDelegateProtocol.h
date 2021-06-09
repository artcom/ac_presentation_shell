//
//  SetupAssistantDelegateProtocol.h
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SetupAssistantController;

@protocol SetupAssistantDelegate

- (void) setupDidFinish: (SetupAssistantController*) sender;

@end
