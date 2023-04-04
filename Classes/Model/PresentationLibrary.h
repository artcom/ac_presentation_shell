//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"
#import "LibraryCategory.h"
#import "LibraryTag.h"

@class ACShellCollection;
@class Presentation;
@class FileCopyController;
@class AssetManager;

@interface PresentationLibrary : NSObject <NSCoding>

@property (strong) ACShellCollection *library;
@property (strong) NSArray *categories;
@property (strong) NSArray *tags;
@property (readonly) BOOL hasLibrary;
@property (assign) BOOL syncSuccessful;
@property (strong) NSString *categoriesDirectory;
@property (assign) BOOL indexing;


+ (instancetype)sharedInstance;
+ (id)libraryFromSettingsFile;

+ (NSString *)libraryDirPath;
+ (NSString *)librarySource;
+ (NSString *)libraryTarget;
+ (BOOL)editingEnabled;

- (BOOL)libraryExistsAtPath;
- (void)loadPresentations;
- (void)saveSettings;
- (BOOL)loadXmlLibraryFromDirectory: (NSString*) directory;
- (void) saveXmlLibrary;

- (NSUInteger)collectionCount;

- (NSXMLElement *) xmlNodeForCategory: (NSString *)aId;
- (NSXMLElement *) xmlNodeForTag: (NSString *)aId;
- (NSXMLElement *)xmlNodeForPresentation:(id)aId;
- (void)syncPresentations;
- (void)checkPresentationsComplete;
- (NSImage *)thumbnailForPresentation: (Presentation *)presentation;
- (void)cacheThumbnails;
- (void)flushThumbnailCache;
- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation;

- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(void (^)(NSArray *))completionBlock;

- (void) updatePresentation: (Presentation*) presentation title: (NSString*) title
              thumbnailPath: (NSString*) thumbnail keynotePath: (NSString*) keynote
                isHighlight: (BOOL) highlightFlag
                       year: (NSInteger) year
                 categories: (NSArray *) categories
                       tags: (NSArray *) tags
           progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void) addPresentationWithTitle: (NSString*) title
                    thumbnailPath: (NSString*) thumbnail
                      keynotePath: (NSString*) keynote
                      isHighlight: (BOOL) highlightFlag
                             year: (NSInteger) year
                       categories: (NSArray *) categories
                             tags: (NSArray *) tags
                 progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void) deletePresentation: (Presentation*) presentation
           progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void)addTag:(NSString *)ID;
- (void)removeTag:(NSInteger)index;
@end
