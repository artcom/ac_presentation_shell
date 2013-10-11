//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"

@class ACShellCollection;
@class Presentation;
@class FileCopyController;
@class AssetManager;

@interface PresentationLibrary : NSObject <NSCoding> {
	NSMutableDictionary *presentationData;
	NSMutableDictionary *thumbnailCache;
    
    AssetManager *assetManager;
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
   
- (NSUInteger)collectionCount;

- (NSXMLElement*) xmlNode:(id)aId;
- (void) syncPresentations;
- (NSImage *)thumbnailForPresentation: (Presentation *)presentation;
- (void)cacheThumbnails;
- (void)flushThumbnailCache;
- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation;

- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(void (^)(NSArray *))completionBlock;

- (void) updatePresentation: (Presentation*) presentation title: (NSString*) title
              thumbnailPath: (NSString*) thumbnail keynotePath: (NSString*) keynote
                isHighlight: (BOOL) highlightFlag 
                       year: (NSInteger) year
           progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void) addPresentationWithTitle: (NSString*) title
                    thumbnailPath: (NSString*) thumbnail 
                      keynotePath: (NSString*) keynote
                      isHighlight: (BOOL) highlightFlag
                             year: (NSInteger) year
                 progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void) deletePresentation: (Presentation*) presentation
           progressDelegate: (id<ProgressDelegateProtocol>) delegate;

@end
