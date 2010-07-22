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
+ (NSString*) libraryFilepath;


- (void)saveSettings;
- (BOOL)loadXmlLibrary;
   
- (NSXMLElement *) xmlNode: (id) aId;

- (void)updateIndices: (NSArray*) thePresentations;

- (NSUInteger)collectionCount;

@end
