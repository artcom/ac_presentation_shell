//
//  NSTableView-WithDelete.m
//  ACShell
//
//  Created by David Siegel on 7/17/10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "NSTableView-WithDelete.h"

@implementation NSTableView ( DeleteKey )
- ( void ) keyDown: ( NSEvent * ) event {
	id obj = [self delegate];
	unichar firstChar = [[event characters] characterAtIndex: 0];
	
	// if the user pressed delete and the delegate supports deleteKeyPressed
	if ( ( firstChar == NSDeleteFunctionKey ||
          firstChar == NSDeleteCharFunctionKey ||
          firstChar == NSDeleteCharacter) &&
        [obj respondsToSelector: @selector( deleteKeyPressed:)] )
    {
		id < DeleteKeyDelegate > delegate = ( id < DeleteKeyDelegate > ) obj;
        
		[delegate deleteKeyPressed: self];
	}
}
@end