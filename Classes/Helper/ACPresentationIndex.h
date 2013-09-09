//
//  ACPresentationIndex.h
//  ACShell
//
//  Created by Patrick Juchli on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPresentationIndex : NSObject {
    SKIndexRef  _indexRef;
}

- (id)initWithPath:(NSString *)libraryPath;
- (BOOL)hasIndex;
- (void)openIndex;
- (void)resetIndex;


- (SKIndexRef)skIndexRef;

@end
