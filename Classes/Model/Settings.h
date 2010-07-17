//
//  Settings.h
//  ACShell
//
//  Created by David Siegel on 7/16/10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PresentationContext;

@interface Settings : NSObject <NSCoding> {
    NSMutableArray* allPresentations;
    NSMutableArray* highlights;
    NSMutableArray* presets;
}

@property (retain) NSMutableArray* allPresentations;
@property (retain) NSMutableArray* highlights;
@property (retain) NSMutableArray* presets;

+ (NSString*) filePath;
- (void) syncWithContext: (PresentationContext*) theContext;

@end
