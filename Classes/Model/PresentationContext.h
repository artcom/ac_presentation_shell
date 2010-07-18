//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationData;
@class Settings;

@interface PresentationContext : NSObject {
	NSMutableDictionary *presentationsData;
    Settings *settings;
	NSString *directory;
}

@property (copy) NSString *directory;
@property (readonly) NSMutableArray *allPresentations;
@property (readonly) NSMutableArray *collections;

#pragma mark TODO: make this a property too
- (NSMutableArray *)highlights;

- (PresentationData *)presentationDataWithId: (NSInteger)aId;
- (void)save;
- (void) loadXmlLibrary;
- (void)syncPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
- (void) dropStalledPresentations: (NSMutableArray*) presentations;
- (void)updateIndices: (NSArray*) thePresentations;

@end
