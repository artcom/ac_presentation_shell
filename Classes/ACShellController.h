//
//  ACShellController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACShellController : NSObject {
	NSMutableArray *presentations;
}

@property (retain, nonatomic) NSMutableArray *presentations;

@end
