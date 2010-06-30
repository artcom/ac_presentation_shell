//
//  KeynoteHandler.h
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Keynote.h"

@interface KeynoteHandler : NSObject {
	KeynoteApplication *application;
}

- (void)open: (NSString *)file;

@end
