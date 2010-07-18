//
//  ACShellCollection.h
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ACShellCollection : NSObject <NSCoding> {
	NSString *name;
	NSMutableArray *presentations;
	NSMutableArray *children;
}

@property (copy) NSString *name;
@property (retain) NSMutableArray *presentations;
@property (retain) NSMutableArray *children;

+ (ACShellCollection *) collectionWithName: (NSString *)theName presentations: (NSMutableArray *)thePresentations children: (NSMutableArray *)theChildren;

@end
