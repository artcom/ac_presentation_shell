//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "ACShellCollection.h"
#import "PresentationDataContext.h"

@class ACShellCollection;
@class Presentation;
@class Settings;

@interface PresentationLibrary : NSObject <PresentationDataContext, NSCoding> {
	NSMutableDictionary *presentationData;
	NSMutableDictionary *thumbnailCache;
    
    ACShellCollection * library;
    NSString * libraryDirPath;
	
	BOOL syncSuccessful;
}

@property (retain, nonatomic) ACShellCollection* library;
@property (readonly) BOOL hasLibrary;
@property (assign) BOOL syncSuccessful;

+ (id)libraryFromSettingsFile;

- (void)saveSettings;
- (BOOL)loadXmlLibraryFromDirectory: (NSString*) directory;
- (void) saveXmlLibrary;
   
- (void)updateIndices: (NSArray*) thePresentations;

- (NSUInteger)collectionCount;

- (void)cacheThumbnails;
- (void)flushThumbnailCache;
- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation;

@end
