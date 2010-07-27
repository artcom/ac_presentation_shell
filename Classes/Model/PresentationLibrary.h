//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACShellCollection;
@class Presentation;
@class FileCopyController;

@interface PresentationLibrary : NSObject <NSCoding> {
	NSMutableDictionary *presentationData;
	NSMutableDictionary *thumbnailCache;
    
    ACShellCollection * library;
    NSString * libraryDirPath;
	
	BOOL syncSuccessful;
}

@property (retain, nonatomic) ACShellCollection* library;
@property (readonly) BOOL hasLibrary;
@property (assign) BOOL syncSuccessful;
@property (readonly) NSString * libraryDirPath;

+ (id)libraryFromSettingsFile;

- (void)saveSettings;
- (BOOL)loadXmlLibraryFromDirectory: (NSString*) directory;
- (void) saveXmlLibrary;
   
- (void)updateIndices: (NSArray*) thePresentations;

- (NSUInteger)collectionCount;

- (NSXMLElement*) xmlNode:(id)aId;
- (void) syncPresentations;
- (NSImage *)thumbnailForPresentation: (Presentation *)presentation;
- (void)cacheThumbnails;
- (void)flushThumbnailCache;
- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation;

- (void) addPresentationWithTitle: (NSString*) title thumbnailPath: (NSString*) thumbnail 
                      keynotePath: (NSString*) keynote isHighlight: (BOOL) highlightFlag
                   copyController: (FileCopyController*) copyController;
@end
