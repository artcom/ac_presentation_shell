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
    
    ACShellCollection * libraryRoot;
}

@property (readonly) NSMutableArray* allPresentations;
@property (readonly) NSMutableArray* highlights;
@property (readonly) NSMutableArray* collections;
@property (retain, nonatomic) ACShellCollection* libraryRoot;

@property (readonly) BOOL hasLibrary;


+ (id)contextFromSettingsFile;

+ (NSString*) libraryDir;
+ (NSString*) settingsFilepath;


- (void)saveSettings;
- (BOOL) loadXmlLibrary;
   
- (NSXMLElement *) xmlNode: (id) aId;
- (void)addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
- (void) dropStalledPresentations: (NSMutableArray*) presentations;
- (void)updateIndices: (NSArray*) thePresentations;

@end
