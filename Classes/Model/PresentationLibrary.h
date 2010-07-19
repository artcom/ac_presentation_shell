//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACShellCollection.h"

@class PresentationData;
@class Settings;

@interface PresentationLibrary : NSObject <NSCoding> {
	NSMutableDictionary *presentationData;
    
    ACShellCollection * library;
}

@property (retain, nonatomic) ACShellCollection* library;

@property (readonly) BOOL hasLibrary;


+ (id)libraryFromSettingsFile;

+ (NSString*) libraryDir;
+ (NSString*) settingsFilepath;


- (void)saveSettings;
- (BOOL)loadXmlLibrary;
   
- (NSXMLElement *) xmlNode: (id) aId;
- (void)addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
- (void) dropStalledPresentations: (NSMutableArray*) presentations;
- (void)updateIndices: (NSArray*) thePresentations;

- (NSUInteger)collectionCount;

@end
