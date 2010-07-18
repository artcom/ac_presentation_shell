//
//  NSTableView-WithDelete.h
//  ACShell
//
//  Created by David Siegel on 7/17/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DeleteKeyDelegate
- ( void ) deleteKeyPressed: ( NSTableView * ) sender;
@end

/*
@interface NSTableView ( DeleteKey )
@end
*/