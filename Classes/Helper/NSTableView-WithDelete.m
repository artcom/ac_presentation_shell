//
//  NSTableView-WithDelete.m
//  ACShell
//
//  Created by David Siegel on 7/17/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "NSTableView-WithDelete.h"

#pragma mark TODO: find a way to catch delete keys
/* This catches the delete key. However, it breaks the usual
   NSArrayController key bindings (cursor- up and down, for example)
 
@implementation NSTableView ( DeleteKey )
- ( void ) keyDown: ( NSEvent * ) event {
	id obj = [self delegate];

    if ([[event characters] length] > 0) {
        unichar firstChar = [[event characters] characterAtIndex: 0];

        if ( ( firstChar == NSDeleteFunctionKey ||
              firstChar == NSDeleteCharFunctionKey ||
              firstChar == NSDeleteCharacter) &&
            [obj respondsToSelector: @selector( deleteKeyPressed:)] )
        {
            id < DeleteKeyDelegate > delegate = ( id < DeleteKeyDelegate > ) obj;

            [delegate deleteKeyPressed: self];
            return;
        }
	}
    [super keyDown: event];
}
@end
*/