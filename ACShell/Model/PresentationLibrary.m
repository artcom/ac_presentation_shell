//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellCollection.h"
#import "PresentationLibrary.h"
#import "LibraryCategory.h"
#import "LibraryTag.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"
#import "localized_text_keys.h"
#import "default_keys.h"
#import "AssetManager.h"
#import "PresentationLibrarySearch.h"


static NSCharacterSet * ourNonDirNameCharSet;


@interface PresentationLibrary ()

@property (weak, readonly) NSMutableArray* allPresentations;
@property (weak, readonly) NSMutableArray* highlights;
@property (weak, readonly) NSMutableArray* collections;
@property (strong, readonly) NSMutableArray* tagged;
@property (strong) NSMutableDictionary *categoryData;
@property (strong) NSMutableDictionary *tagData;
@property (strong) NSMutableDictionary *presentationData;
@property (strong) AssetManager *assetManager;
@property (strong) PresentationLibrarySearch *librarySearch;
@property (strong) NSMutableDictionary *thumbnailCache;

+ (NSString*) settingsFilepath;
- (void) initCollections;
- (void) syncPresentations;
- (void) addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
- (void) dropStalledPresentations: (NSMutableArray*) thePresentations notMatchingPredicate: (NSPredicate *)thePredicate;
- (void) updateIndices: (NSMutableArray*) thePresentations;
- (NSString*) subdirectoryFromTitle: (NSString*) aTitle;

@end


@implementation PresentationLibrary

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PresentationLibrary *_sharedInstance = nil;
    dispatch_once(&once, ^{
        _sharedInstance = [self libraryFromSettingsFile];
        [_sharedInstance loadPresentations];
    });
    
    return _sharedInstance;
}

+ (id) libraryFromSettingsFile {
    PresentationLibrary * lib = [NSKeyedUnarchiver unarchiveObjectWithFile: [PresentationLibrary settingsFilepath]];
    if (lib != nil) {
        return lib;
    }
    return PresentationLibrary.new;
}

-(id) init {
    self = [super init];
    if (self != nil) {
        [self initCollections];
        self.indexing = YES;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        [self initCollections];
        [self.allPresentations addObjectsFromArray: [aDecoder decodeObjectForKey: ACSHELL_STR_ALL]];
        [self.highlights addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_HIGHLIGHTS]];
        [self.collections addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_COLLECTIONS]];
        [self.tagged addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_TAGS]];
        self.indexing = YES;
        
        [self.library assignContext: self];
    }
    
    return self;
}

- (void)loadPresentations {
    [self loadXmlLibraryFromDirectory:PresentationLibrary.libraryDirPath];
}

-(void) initCollections {
    self.thumbnailCache = NSMutableDictionary.new;
    
    self.categoryData = nil;
    self.tagData = nil;
    self.presentationData = nil;
    
    self.library = [ACShellCollection collectionWithName: @"root"];
    ACShellCollection *lib = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_LIBRARY, nil)];
    [self.library.children addObject: lib];
    
    ACShellCollection *all = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_ALL, nil)];
    [lib.children addObject: all];
    ACShellCollection *highlights = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_HIGHLIGHTS, nil)];
    [lib.children addObject: highlights];
    
    ACShellCollection *collections = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_COLLECTIONS, nil)];
    [self.library.children addObject: collections];
    
    ACShellCollection *tagged = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_TAGS, nil)];
    [self.library.children addObject: tagged];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: self.allPresentations forKey:ACSHELL_STR_ALL];
    [aCoder encodeObject: self.highlights forKey:ACSHELL_STR_HIGHLIGHTS];
    [aCoder encodeObject: self.collections forKey:ACSHELL_STR_COLLECTIONS];
    [aCoder encodeObject: self.tagged forKey:ACSHELL_STR_TAGS];
}

- (void)saveSettings {
    [self.allPresentations sortUsingSelector:@selector(compareByOrder:)];
    [NSKeyedArchiver archiveRootObject: self toFile:[PresentationLibrary settingsFilepath]];
}

- (BOOL)loadXmlLibraryFromDirectory:(NSString *)directory {
    [self flushThumbnailCache];
    self.categoryData = nil;
    self.tagData = nil;
    self.presentationData = nil;
    
    NSString *libraryPath = PresentationLibrary.libraryFilePath;
    self.categoryData = [NSMutableDictionary new];
    self.tagData = [NSMutableDictionary new];
    self.presentationData = [NSMutableDictionary new];
    
    if ( ! [NSFileManager.defaultManager fileExistsAtPath: libraryPath]) {
        NSLog(@"file '%@' does not exist", libraryPath);
        return NO;
    }
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error];
    
    NSXMLElement *categoriesElement = [document nodesForXPath:@"./library/categories" error:&error].firstObject;
    self.categoriesDirectory = [[categoriesElement attributeForName:@"directory"] stringValue];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }
    
    NSArray *xmlCategories = [document nodesForXPath:@"./library/categories/category" error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }
    
    NSArray *xmlTags = [document nodesForXPath:@"./library/tags/tag" error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }
    
    NSArray *xmlPresentations = [document nodesForXPath:@"./library/presentations/presentation" error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }
    
    for (NSXMLElement *element in xmlCategories) {
        [self.categoryData setObject:element forKey: [[element attributeForName:@"index"]objectValue]];
    }
    
    for (NSXMLElement *element in xmlTags) {
        [self.tagData setObject:element forKey: [[element attributeForName:@"id"]objectValue]];
    }
    
    for (NSXMLElement * element in xmlPresentations) {
        [self.presentationData setObject: element forKey: [[element attributeForName:@"id"] objectValue]];
    }
    
    [xmlCategories makeObjectsPerformSelector:@selector(detach)];
    [xmlTags makeObjectsPerformSelector:@selector(detach)];
    [xmlPresentations makeObjectsPerformSelector:@selector(detach)];
    
    [self createCategories];
    [self createTags];
    [self syncPresentations];
    [self cacheThumbnails];
    
    if (self.indexing) {
        self.librarySearch = [[PresentationLibrarySearch alloc] initWithLibraryPath:PresentationLibrary.libraryDirPath];
        [self.librarySearch updateIndex];
    }
    
    return YES;
}

+ (BOOL)editingEnabled {
    return [NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED];
}

+ (BOOL)libraryExistsAtPath
{
    return PresentationLibrary.libraryDirPath != nil && [NSFileManager.defaultManager fileExistsAtPath: PresentationLibrary.libraryDirPath];
}

+ (NSString*) libraryDirPath {
    return [NSUserDefaults.standardUserDefaults  stringForKey: ACSHELL_DEFAULT_KEY_STORAGE_LOCATION];
}

+ (NSString *) libraryFilePath {
    return [self.libraryDirPath stringByAppendingPathComponent:ACShellLibraryFile];
}

- (void) saveXmlLibrary {
    NSXMLElement *root = [[NSXMLElement alloc] initWithName: @"library"];
    NSXMLElement *categories = [[NSXMLElement alloc] initWithName:@"categories"];
    NSXMLElement *tags = [[NSXMLElement alloc] initWithName:@"tags"];
    NSXMLElement *presentations = [[NSXMLElement alloc] initWithName:@"presentations"];
    [root addChild:categories];
    [root addChild:tags];
    [root addChild:presentations];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:root];
    [document setCharacterEncoding:@"UTF-8"];
    
    [categories addAttribute: [NSXMLNode attributeWithName: @"directory" stringValue:self.categoriesDirectory]];
    
    for (LibraryCategory *c in self.categories) {
        [categories addChild:self.categoryData[c.ID]];
    }
    
    for (LibraryTag *t in self.tags) {
        [tags addChild:self.tagData[t.ID]];
    }
    
    for (Presentation* p in self.allPresentations) {
        [presentations addChild:self.presentationData[p.presentationId]];
    }
    
    NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![xmlData writeToFile:PresentationLibrary.libraryFilePath atomically:YES]) {
        NSLog(@"Failed to save xml file.");
    }
    
    [self.categoryData.allValues makeObjectsPerformSelector:@selector(detach)];
    [self.tagData.allValues makeObjectsPerformSelector:@selector(detach)];
    [self.presentationData.allValues makeObjectsPerformSelector:@selector(detach)];
    
    [NSNotificationCenter.defaultCenter postNotificationName:ACShellLibraryDidUpdate object:nil];
}

- (NSXMLElement *) xmlNodeForCategory: (NSString *)aId
{
    return [self.categoryData objectForKey: aId];
}

- (NSXMLElement *) xmlNodeForTag: (NSString *)aId
{
    return [self.tagData objectForKey: aId];
}

- (NSXMLElement *) xmlNodeForPresentation: (id)aId {
    if ([self hasLibrary]) {
        return [self.presentationData objectForKey: aId];
    }
    return nil;
}


#pragma mark - Full-text search


- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(void (^)(NSArray *))completionBlock {
    
    [self.librarySearch searchFullText:query maxNumResults:maxNumResults completion:completionBlock];
}


#pragma mark - Thumbnails


- (NSImage *)thumbnailForPresentation: (Presentation *)presentation {
    NSImage *thumbnail = [self.thumbnailCache objectForKey:presentation.presentationId];
    
    if (thumbnail == nil) {
        NSString *filepath = [PresentationLibrary.libraryDirPath stringByAppendingPathComponent: presentation.relativeThumbnailPath];
        thumbnail =  [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
        if (thumbnail != nil) {
            [self.thumbnailCache setObject:thumbnail forKey:presentation.presentationId];
        }
    }
    
    return thumbnail;
}

- (void)flushThumbnailCache {
    [self.thumbnailCache removeAllObjects];
}

- (void)cacheThumbnails {
    for (Presentation *presentation in self.allPresentations) {
        [self thumbnailForPresentation:presentation];
    }
}

- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation {
    [self.thumbnailCache removeObjectForKey:presentation.presentationId];
}

- (NSUInteger)collectionCount {
    return [self.collections count];
}

- (void)addTag:(NSString *)ID
{
    NSXMLElement * node = [NSXMLElement elementWithName: @"tag"];
    [node addAttribute: [NSXMLNode attributeWithName: @"id" stringValue: ID]];
    [self.tagData setObject: node forKey: ID];
    
    LibraryTag *tag = [[LibraryTag alloc] initWithId:ID inContext:self];
    NSMutableArray *tags = _tags.mutableCopy;
    [tags addObject:tag];
    _tags = [self sortTags:tags];
}

- (void)removeTag:(NSInteger)index
{
    // remove tag from all presentations
    LibraryTag *tag = _tags[index];
    [self.allPresentations enumerateObjectsUsingBlock:^(Presentation *presentation, __unused NSUInteger index, __unused BOOL * _Nonnull stop) {
        NSMutableArray *tags = presentation.tags.mutableCopy;
        [tags removeObject:tag.ID];
        presentation.tags = tags;
    }];
    
    // remove tag from library
    NSMutableArray *tags = _tags.mutableCopy;
    [tags removeObjectAtIndex:index];
    _tags = [self sortTags:tags];
}

- (void) addPresentationWithTitle: (NSString*) title
                    thumbnailPath: (NSString*) thumbnail
                      keynotePath: (NSString*) keynote
                      isHighlight: (BOOL) highlightFlag
                             year: (NSInteger) year
                       categories: (NSArray *) categories
                             tags: (NSArray *) tags
                 progressDelegate: (id<ProgressDelegateProtocol>) delegate
{
    NSString * newId = NSUUID.UUID.UUIDString;
    NSXMLElement * node = [NSXMLElement elementWithName: @"presentation"];
    [node addAttribute: [NSXMLNode attributeWithName: @"directory" stringValue: @""]];
    [node addAttribute: [NSXMLNode attributeWithName: @"highlight" stringValue: @""]];
    [node addAttribute: [NSXMLNode attributeWithName: @"id" stringValue: newId]];
    [node addChild: [NSXMLElement elementWithName: @"title"]];
    [node addChild: [NSXMLElement elementWithName: @"file"]];
    [node addChild: [NSXMLElement elementWithName: @"thumbnail"]];
    
    [self.presentationData setObject: node forKey: newId];
    
    Presentation *presentation = [[Presentation alloc] initWithId: newId inContext: self];
    presentation.directory = [self subdirectoryFromTitle: title];
    if ([NSFileManager.defaultManager fileExistsAtPath: presentation.directory]) {
        presentation.directory = [NSString stringWithFormat: @"%@-%@", presentation.directory, presentation.presentationId];
    }
    NSError * error;
    if ( ! [NSFileManager.defaultManager createDirectoryAtPath: presentation.absoluteDirectory
                                   withIntermediateDirectories: YES attributes: nil error: &error])
    {
        NSLog(@"Failed to create directory: %@", error);
        return;
    }
    
    presentation.title = title;
    presentation.highlight = highlightFlag;
    presentation.year = [NSNumber numberWithInteger: year];
    presentation.presentationFilename = keynote.lastPathComponent;
    presentation.thumbnailFilename = thumbnail.lastPathComponent;
    presentation.categories = [categories valueForKeyPath:@"ID"];
    presentation.tags = [tags valueForKeyPath:@"ID"];
    
    [self.allPresentations insertObject: presentation atIndex:0];
    [self updateIndices: self.allPresentations];
    if (presentation.highlight) {
        Presentation *pCopy = [presentation copy];
        [self.highlights insertObject: pCopy atIndex: 0];
        [self updateIndices: self.highlights];
    }
    
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: presentation progressDelegate: delegate libraryDelegate:self];
    [assetMan copyAsset: thumbnail];
    [assetMan copyAsset: keynote];
    
    self.assetManager = assetMan;
    [self.assetManager run];
    
    [self saveXmlLibrary];
}

- (void) updatePresentation: (Presentation*) presentation title: (NSString*) title
              thumbnailPath: (NSString*) thumbnail keynotePath: (NSString*) keynote
                isHighlight: (BOOL) highlightFlag
                       year: (NSInteger) year
                 categories: (NSArray *) categories
                       tags: (NSArray *) tags
           progressDelegate: (id<ProgressDelegateProtocol>) delegate
{
    BOOL xmlChanged = NO;
    if (presentation.highlight != highlightFlag) {
        presentation.highlight = highlightFlag;
        xmlChanged = YES;
    }
    if ([presentation.year integerValue] != year) {
        presentation.year = [NSNumber numberWithInteger: year];
        xmlChanged = YES;
    }
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: presentation progressDelegate: delegate libraryDelegate:self];
    
    if ( ! [thumbnail isEqual: presentation.absoluteThumbnailPath]) {
        if (presentation.thumbnailFileExists) {
            NSError *error;
            [NSFileManager.defaultManager removeItemAtPath:presentation.absoluteThumbnailPath error:&error];
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }
        [assetMan copyAsset: thumbnail];
        
        presentation.thumbnailFilename = thumbnail.lastPathComponent;
        
        [self flushThumbnailCacheForPresentation: presentation];
        
        xmlChanged = YES;
    }
    
    if ( ! [keynote isEqual: presentation.absolutePresentationPath]) {
        if (presentation.presentationFileExists) {
            NSError *error;
            [NSFileManager.defaultManager removeItemAtPath:presentation.absolutePresentationPath error:&error];
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }
        [assetMan copyAsset: keynote];
        
        presentation.presentationFilename = keynote.lastPathComponent;
        
        xmlChanged = YES;
    }
    
    if ( ! [title isEqual: presentation.title]) {
        presentation.title = title;
        xmlChanged = YES;
        NSString * newDir = [self subdirectoryFromTitle: title];
        if ( ! [presentation.directory isEqual: newDir]) {
            if ([NSFileManager.defaultManager fileExistsAtPath: newDir]) {
                newDir = [NSString stringWithFormat: @"%@-%@", newDir, presentation.presentationId];
            }
            NSString * newDirPath  = [PresentationLibrary.libraryDirPath stringByAppendingPathComponent: newDir];
            NSError * error;
            [NSFileManager.defaultManager moveItemAtPath: presentation.absoluteDirectory
                                                  toPath: newDirPath
                                                   error: &error];
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
            presentation.directory = newDir;
        }
    }
    if ( ![categories isEqual: presentation.categories]) {
        presentation.categories = [categories valueForKeyPath:@"ID"];
        xmlChanged = YES;
    }
    if ( ![tags isEqual: presentation.tags]) {
        presentation.tags = [tags valueForKeyPath:@"ID"];
        xmlChanged = YES;
    }
    self.assetManager = assetMan;
    [self.assetManager run];
    
    if (xmlChanged) {
        [self saveXmlLibrary];
    }
}

- (void) deletePresentation: (Presentation*) presentation
           progressDelegate: (id<ProgressDelegateProtocol>) delegate
{
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: presentation progressDelegate: delegate libraryDelegate:self];
    [assetMan trashAsset: presentation.absoluteDirectory];
    self.assetManager = assetMan;
    
    [self.assetManager run];
    
    [self.presentationData removeObjectForKey: presentation.presentationId];
    [self syncPresentations];
    [self saveXmlLibrary];
}

#pragma mark -
#pragma mark Private Methods
- (NSMutableArray*) allPresentations {
    ACShellCollection *collection = self.library.children[0];
    ACShellCollection *child = collection.children[0];
    return child.presentations;
}

- (NSMutableArray*) highlights {
    ACShellCollection *collection = self.library.children[0];
    ACShellCollection *child = collection.children[1];
    return child.presentations;
}

- (NSMutableArray*) collections {
    return (NSMutableArray*)[[self.library.children objectAtIndex:1] children];
}

- (NSMutableArray*) tagged {
    return (NSMutableArray*)[[self.library.children objectAtIndex:2] children];
}

- (void) dropStalledPresentations: (NSMutableArray*) thePresentations notMatchingPredicate: (NSPredicate *)thePredicate {
    BOOL droppedStuff = NO;
    for (NSInteger i = [thePresentations count] - 1; i >= 0; i--) {
        Presentation* presentation = (Presentation*) [thePresentations objectAtIndex: i];
        if ([self xmlNodeForPresentation: presentation.presentationId] == nil || (thePredicate != nil && ![thePredicate evaluateWithObject:presentation])) {
            
            [thePresentations removeObjectAtIndex: i];
            droppedStuff = YES;
        }
    }
    if (droppedStuff) {
        [self updateIndices: thePresentations];
    }
}

- (void)addNewPresentations: (NSMutableArray*) thePresentations withPredicate: (NSPredicate *) thePredicate {
    NSMutableArray * presentIds = NSMutableArray.new;
    for (Presentation* presentation in thePresentations) {
        [presentIds addObject: presentation.presentationId];
    }
    BOOL addedStuff = NO;
    for (NSNumber * key in self.presentationData) {
        if (NSNotFound == [presentIds indexOfObject: key]) {
            Presentation * newPresentation = [[Presentation alloc] initWithId: key inContext:self];
            if (thePredicate == nil || [thePredicate evaluateWithObject:newPresentation]) {
                [thePresentations insertObject: newPresentation atIndex:0];
                addedStuff = YES;
            }
        }
    }
    
    if (addedStuff) {
        [self updateIndices: thePresentations];
    }
}

- (void)createCategories
{
    NSMutableArray *categories = [NSMutableArray new];
    for (NSString *ID in self.categoryData) {
        LibraryCategory *category = [[LibraryCategory alloc] initWithId:ID inContext:self];
        [categories addObject:category];
    }
    
    _categories = [categories sortedArrayUsingComparator:^NSComparisonResult(LibraryCategory *category1, LibraryCategory *category2) {
        if ([category1.index isGreaterThan:category2.index]) {
            return NSOrderedDescending;
        }
        if ([category1.index isLessThan:category2.index]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)createTags
{
    NSMutableArray *tags = [NSMutableArray new];
    for (NSString *title in self.tagData) {
        LibraryTag *tag = [[LibraryTag alloc] initWithId:title inContext:self];
        [tags addObject:tag];
    }
    _tags = [self sortTags:tags];
}

- (NSArray *)sortTags:(NSArray *)tags
{
    return [tags sortedArrayUsingComparator:^NSComparisonResult(LibraryTag *tag1, LibraryTag *tag2) {
        if ([tag1.ID isGreaterThan:tag2.ID]) {
            return NSOrderedDescending;
        }
        if ([tag1.ID isLessThan:tag2.ID]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)checkPresentationsComplete
{
    [self.allPresentations makeObjectsPerformSelector:@selector(checkComplete)];
    [self.highlights makeObjectsPerformSelector:@selector(checkComplete)];
    for (ACShellCollection *collection in self.collections) {
        [collection.presentations makeObjectsPerformSelector:@selector(checkComplete)];
    }
    for (ACShellCollection *collection in self.tagged) {
        [collection.presentations makeObjectsPerformSelector:@selector(checkComplete)];
    }
}

-(void) syncPresentations {
    
    // Here we initialize the presentations
    [self dropStalledPresentations: self.allPresentations notMatchingPredicate: nil];
    [self addNewPresentations: self.allPresentations withPredicate: nil];
    
    // Here we initialize the highlights
    NSPredicate *highlightPredicate = [NSPredicate predicateWithFormat:@"highlight == YES"];
    [self dropStalledPresentations: self.highlights notMatchingPredicate: highlightPredicate];
    [self addNewPresentations:  self.highlights withPredicate: highlightPredicate];
    
    for (ACShellCollection *collection in self.collections) {
        [self dropStalledPresentations:collection.presentations notMatchingPredicate: nil];
    }
    
    // Add a parent collection for each tag
    [self.tagged removeAllObjects];
    for (LibraryTag *tag in self.tags) {
        ACShellCollection *collection = [ACShellCollection collectionWithName:tag.ID];
        [self.tagged addObject:collection];
    }
    
    // Add presentations to tag collection
    for (ACShellCollection *collection in self.tagged) {
        NSPredicate *taggedPredicate = [NSPredicate predicateWithFormat:@"tags CONTAINS %@", collection.name];
        [self dropStalledPresentations: collection.presentations notMatchingPredicate: taggedPredicate];
        [self addNewPresentations: collection.presentations withPredicate: taggedPredicate];
    }
    
    [self checkPresentationsComplete];
}

- (void)updateIndices: (NSMutableArray*) thePresentations {
    int i = 0;
    for (Presentation* presentation in thePresentations) {
        presentation.order = ++i;
    }
}

- (BOOL) hasLibrary {
    return [self.presentationData count] > 0;
}

+ (NSString*) settingsFilepath {
    return [[NSFileManager.defaultManager applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];
}

- (NSString*) subdirectoryFromTitle: (NSString*) aTitle {
    if ( ! ourNonDirNameCharSet ) {
        NSMutableCharacterSet * workingSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz01234567890"] mutableCopy];
        [workingSet addCharactersInString: @"_-."];
        [workingSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [workingSet invert];
        ourNonDirNameCharSet = [workingSet copy];
    }
    NSString * str = [[aTitle.lowercaseString componentsSeparatedByCharactersInSet:ourNonDirNameCharSet] componentsJoinedByString: @""];
    NSArray * words = [str componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return [words componentsJoinedByString: @"_"];
}


#pragma mark LibraryDelegateProtocol Methods

- (void)operationDidFinish
{
    if (self.indexing) {
        [self.librarySearch updateIndex];
    }
}

- (void)operationDidFinishWithError:(NSError *)error {}

@end
