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
    NSString * libraryDirPath;
}

@property (retain, nonatomic) ACShellCollection* library;
@property (readonly) BOOL hasLibrary;
@property (readonly) NSString* libraryDirPath;
@property (assign) BOOL syncSuccessful;

+ (id)libraryFromSettingsFile;

- (void)saveSettings;
- (BOOL)loadXmlLibraryFromDirectory: (NSString*) directory;
   
- (NSXMLElement *) xmlNode: (id) aId;

- (void)updateIndices: (NSArray*) thePresentations;

- (NSUInteger)collectionCount;

@end
