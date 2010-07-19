//
//  Settings.h
//  ACShell
//
//  Created by David Siegel on 7/16/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PresentationLibrary;

@interface Settings : NSObject <NSCoding> {
    NSMutableArray* allPresentations;
    NSMutableArray* highlights;
    NSMutableArray* collections;
}

@property (retain) NSMutableArray* allPresentations;
@property (retain) NSMutableArray* highlights;
@property (retain) NSMutableArray* collections;

+ (NSString*) filePath;
- (void) syncWithContext: (PresentationLibrary*) theContext;

@end
