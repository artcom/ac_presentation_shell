//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellCollection.h"
#import "PresentationLibrary.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"
#import "NSString-WithUUID.h"
#import "localized_text_keys.h"
#import "AssetManager.h"
#import "PresentationLibrarySearch.h"



#define ACSHELL_SYNC_SUCCESSFUL @"syncSuccessful"

static NSCharacterSet * ourNonDirNameCharSet;


@interface PresentationLibrary ()

@property (readonly) NSMutableArray* allPresentations;
@property (readonly) NSMutableArray* highlights;
@property (readonly) NSMutableArray* collections;
@property (nonatomic, retain) NSMutableDictionary *presentationData;
@property (nonatomic, retain) AssetManager *assetManager;
@property (nonatomic, retain) PresentationLibrarySearch *librarySearch;

+ (NSString*) settingsFilepath;
- (void) setup;
- (void) syncPresentations;
- (void) addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
- (void) dropStalledPresentations: (NSMutableArray*) thePresentations notMatchingPredicate: (NSPredicate *)thePredicate;
- (void) updateIndices: (NSMutableArray*) thePresentations;
- (NSString*) subdirectoryFromTitle: (NSString*) aTitle;

@end


@implementation PresentationLibrary
@synthesize library;
@synthesize syncSuccessful;
@synthesize libraryDirPath;
@synthesize presentationData;
@synthesize assetManager;

+ (id) libraryFromSettingsFile {
    PresentationLibrary * lib = [NSKeyedUnarchiver unarchiveObjectWithFile: [PresentationLibrary settingsFilepath]];
    if (lib != nil) {
        return lib;
    }
    return [[[PresentationLibrary alloc] init] autorelease];
}

-(id) init {
	self = [super init];
	if (self != nil) {
        [self setup];
        self.syncSuccessful = YES;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
        [self setup];
        [self.allPresentations addObjectsFromArray: [aDecoder decodeObjectForKey: ACSHELL_STR_ALL]];
        [self.highlights addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_HIGHLIGHTS]];
        [self.collections addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_COLLECTIONS]];
        
        self.syncSuccessful = [aDecoder decodeBoolForKey: ACSHELL_SYNC_SUCCESSFUL];
        
        [library assignContext: self];
    }

	return self;
}

-(void) setup {
	thumbnailCache = [[NSMutableDictionary alloc] init];
	
    self.presentationData = nil;
    library = [[ACShellCollection collectionWithName: @"root"] retain];
    ACShellCollection *lib = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_LIBRARY, nil)];
    [library.children addObject: lib];
    
    ACShellCollection *all = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_ALL, nil)];
    [lib.children addObject: all];
    ACShellCollection *highlights = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_STR_HIGHLIGHTS, nil)];
    [lib.children addObject: highlights];
    
    ACShellCollection *collections = [ACShellCollection collectionWithName: NSLocalizedString( ACSHELL_STR_COLLECTIONS, nil)];
    [library.children addObject: collections];
}

- (void) dealloc {
    [presentationData release];
	[thumbnailCache release];
	[library release];
    [libraryDirPath release];
    [assetManager release];
    [_librarySearch release];

	[super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {	
	[aCoder encodeObject: self.allPresentations forKey:ACSHELL_STR_ALL];
	[aCoder encodeObject: self.highlights forKey:ACSHELL_STR_HIGHLIGHTS];
	[aCoder encodeObject: self.collections forKey:ACSHELL_STR_COLLECTIONS];
    [aCoder encodeBool: self.syncSuccessful forKey: ACSHELL_SYNC_SUCCESSFUL];
}

- (void)saveSettings {
    [self.allPresentations sortUsingSelector:@selector(compareByOrder:)];
	[NSKeyedArchiver archiveRootObject: self toFile:[PresentationLibrary settingsFilepath]];	
}

- (BOOL)loadXmlLibraryFromDirectory:(NSString*) directory {
    
	[self flushThumbnailCache];
	self.presentationData = nil;
    [libraryDirPath release];
    libraryDirPath = [directory retain];
    
    NSString *libraryPath = [directory stringByAppendingPathComponent:@"library.xml"];
    presentationData = [[NSMutableDictionary alloc] init];
    
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath: libraryPath]) {
        NSLog(@"file '%@' does not exist", libraryPath);
        return NO;
    }
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error];
    NSArray *xmlPresentations = [document nodesForXPath:@"./presentations/presentation" error:&error];
    [document release];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }
    
    for (NSXMLElement * element in xmlPresentations) {
		[presentationData setObject: element forKey: [[element attributeForName:@"id"] objectValue]];
		[element detach];
    }
    
    [self syncPresentations];
	[self cacheThumbnails];
    
    PresentationLibrarySearch *librarySearch = [[PresentationLibrarySearch alloc] initWithLibraryPath:self.libraryDirPath];
    self.librarySearch = librarySearch;
    [librarySearch release];
    
    [self.librarySearch updateIndex];
    
    return YES;
}

- (void) saveXmlLibrary {
    NSXMLElement * root = [[[NSXMLElement alloc] initWithName: @"presentations"] autorelease];
    NSXMLDocument * document = [[[NSXMLDocument alloc] initWithRootElement: root] autorelease];
    for (Presentation* p in self.allPresentations) {
        [root addChild: [presentationData objectForKey: p.presentationId]];
    }

    NSData *xmlData = [document XMLDataWithOptions: NSXMLNodePrettyPrint];
    if (![xmlData writeToFile: [self.libraryDirPath stringByAppendingPathComponent:@"library.xml"] atomically:YES]) {
        NSLog(@"Failed to save xml file.");
    }
	
	for (id key in presentationData) {
		NSXMLElement * element = [presentationData objectForKey: key];
		[element detach];
	}
}

- (NSXMLElement *) xmlNode: (id)aId {
	if ([self hasLibrary]) {
        return [presentationData objectForKey: aId];
    }
    return nil;
}


#pragma mark - Full-text search


- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(void (^)(NSArray *))completionBlock {
    
    [self.librarySearch searchFullText:query maxNumResults:maxNumResults completion:completionBlock];
}


#pragma mark - Thumbnails


- (NSImage *)thumbnailForPresentation: (Presentation *)presentation {
	NSImage *thumbnail = [thumbnailCache objectForKey:presentation.presentationId]; 

	if (thumbnail == nil) {
		NSString *filepath = [[self libraryDirPath] stringByAppendingPathComponent: presentation.relativeThumbnailPath];
		thumbnail =  [[[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]] autorelease];
		if (thumbnail != nil) {
            [thumbnailCache setObject:thumbnail forKey:presentation.presentationId];
        }
	}
	
	return thumbnail;
}

- (void)flushThumbnailCache {
	[thumbnailCache removeAllObjects];
}

- (void)cacheThumbnails {
	for (Presentation *presentation in self.allPresentations) {
		[self thumbnailForPresentation:presentation];
	}
}

- (void)flushThumbnailCacheForPresentation: (Presentation *)presentation {
	[thumbnailCache removeObjectForKey:presentation.presentationId];
}

- (NSUInteger)collectionCount {
	return [self.collections count];
}

- (void) addPresentationWithTitle: (NSString*) title
                    thumbnailPath: (NSString*) thumbnail 
                      keynotePath: (NSString*) keynote
                      isHighlight: (BOOL) highlightFlag
                             year: (NSInteger) year
                 progressDelegate: (id<ProgressDelegateProtocol>) delegate
{
    
    NSString * newId = [NSString stringWithUUID];
    NSXMLElement * node = [NSXMLElement elementWithName: @"presentation"];
    [node addAttribute: [NSXMLNode attributeWithName: @"directory" stringValue: @""]];
    [node addAttribute: [NSXMLNode attributeWithName: @"highlight" stringValue: @""]];
    [node addAttribute: [NSXMLNode attributeWithName: @"id" stringValue: newId]];
    [node addChild: [NSXMLElement elementWithName: @"title"]];
    [node addChild: [NSXMLElement elementWithName: @"file"]];
    [node addChild: [NSXMLElement elementWithName: @"thumbnail"]];

    [presentationData setObject: node forKey: newId];

    Presentation * p = [[[Presentation alloc] initWithId: newId inContext: self] autorelease];
    p.directory = [self subdirectoryFromTitle: title];
    if ([[NSFileManager defaultManager] fileExistsAtPath: p.directory]) {
        p.directory = [NSString stringWithFormat: @"%@-%@", p.directory, p.presentationId];
    }
    NSError * error;
    if ( ! [[NSFileManager defaultManager] createDirectoryAtPath: p.absoluteDirectory 
                                     withIntermediateDirectories: YES attributes: nil error: &error])
    {
        NSLog(@"Failed to create directory: %@", error);
        return;
    }
    
    p.title = title;
    p.highlight = highlightFlag;
    p.year = [NSNumber numberWithInteger: year];
    p.presentationFilename = [keynote lastPathComponent];
    p.thumbnailFilename = [thumbnail lastPathComponent];
    
    [self.allPresentations insertObject: p atIndex:0];
    [self updateIndices: self.allPresentations];
    if (p.highlight) {
        Presentation *pCopy = [p copy];
        [self.highlights insertObject: pCopy atIndex: 0];
        [pCopy release];
        [self updateIndices: self.highlights];
    }
    
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: p progressDelegate: delegate];
    [assetMan copyAsset: thumbnail];
    [assetMan copyAsset: keynote];
    
    self.assetManager = assetMan;
    [assetMan release];
    [self.assetManager run];
    
    [self saveXmlLibrary];
}

- (void) updatePresentation: (Presentation*) presentation title: (NSString*) title
              thumbnailPath: (NSString*) thumbnail keynotePath: (NSString*) keynote
                isHighlight: (BOOL) highlightFlag 
                       year: (NSInteger) year
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
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: presentation progressDelegate: delegate];
    
    if ( ! [thumbnail isEqual: presentation.absoluteThumbnailPath]) {
        if (presentation.thumbnailFileExists) {
            [assetMan trashAsset: presentation.absoluteThumbnailPath];
        }
        [assetMan copyAsset: thumbnail];
        
        presentation.thumbnailFilename = [thumbnail lastPathComponent];
        
        [self flushThumbnailCacheForPresentation: presentation];

        xmlChanged = YES;
    }
    
    if ( ! [keynote isEqual: presentation.absolutePresentationPath]) {
        if (presentation.presentationFileExists) {
            [assetMan trashAsset: presentation.absolutePresentationPath];
        }
        [assetMan copyAsset: keynote];
        
        presentation.presentationFilename = [keynote lastPathComponent];
        
        xmlChanged = YES;
    }
    
    if ( ! [title isEqual: presentation.title]) {
        presentation.title = title;
        xmlChanged = YES;
        NSString * newDir = [self subdirectoryFromTitle: title];
        if ( ! [presentation.directory isEqual: newDir]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath: newDir]) {
                newDir = [NSString stringWithFormat: @"%@-%@", newDir, presentation.presentationId];
            }
            NSString * newDirPath  = [self.libraryDirPath stringByAppendingPathComponent: newDir];
            // TODO error handling
            NSError * error;
            [[NSFileManager defaultManager] moveItemAtPath: presentation.absoluteDirectory
                                                    toPath: newDirPath
                                                     error: &error];
            presentation.directory = newDir;
        }
    }
    self.assetManager = assetMan;
    [assetMan release];
    
    [self.assetManager run];
    
    if (xmlChanged) {
        [self saveXmlLibrary];
    }
}

- (void) deletePresentation: (Presentation*) presentation
           progressDelegate: (id<ProgressDelegateProtocol>) delegate
{
    AssetManager * assetMan = [[AssetManager alloc] initWithPresentation: presentation progressDelegate: delegate];
    [assetMan trashAsset: presentation.absoluteDirectory];
    self.assetManager = assetMan;
    [assetMan release];
    
    [self.assetManager run];
    
    [presentationData removeObjectForKey: presentation.presentationId];
    [self syncPresentations];
    [self saveXmlLibrary];
}
    
#pragma mark -
#pragma mark Private Methods
- (NSMutableArray*) allPresentations {
    return (NSMutableArray*)[[[[library.children objectAtIndex: 0] children] objectAtIndex: 0] presentations];
}

- (NSMutableArray*) highlights {
    return (NSMutableArray*)[[[[library.children objectAtIndex: 0] children] objectAtIndex: 1] presentations];
}

- (NSMutableArray*) collections {
    return (NSMutableArray*)[[library.children objectAtIndex: 1] children];
}

- (void) dropStalledPresentations: (NSMutableArray*) thePresentations notMatchingPredicate: (NSPredicate *)thePredicate {
    BOOL droppedStuff = NO;
    for (int i = [thePresentations count] - 1; i >= 0; i--) {
        Presentation* presentation = (Presentation*) [thePresentations objectAtIndex: i];
        if ([self xmlNode: presentation.presentationId] == nil || (thePredicate != nil && ![thePredicate evaluateWithObject:presentation])) {

			[thePresentations removeObjectAtIndex: i];
            droppedStuff = YES;
        }
    }
    if (droppedStuff) {
        [self updateIndices: thePresentations];
    }
}

- (void)addNewPresentations: (NSMutableArray*) thePresentations withPredicate: (NSPredicate *) thePredicate {
    NSMutableArray * presentIds = [[[NSMutableArray alloc] init] autorelease];
    for (Presentation* presentation in thePresentations) {
        [presentIds addObject: presentation.presentationId];
    }
    BOOL addedStuff = NO;
    for (NSNumber * key in presentationData) {
        if (NSNotFound == [presentIds indexOfObject: key]) {
            Presentation * newPresentation = [[Presentation alloc] initWithId: key inContext:self];
            if (thePredicate == nil || [thePredicate evaluateWithObject:newPresentation]) {
                [thePresentations insertObject: newPresentation atIndex:0];
                addedStuff = YES;
            }
            [newPresentation release];
        }
    }
	
    if (addedStuff) {
        [self updateIndices: thePresentations];
    }
}

-(void) syncPresentations {
    [self dropStalledPresentations: self.allPresentations notMatchingPredicate: nil];
    [self addNewPresentations: self.allPresentations withPredicate: nil];
	
	NSPredicate *highlightPredicate = [NSPredicate predicateWithFormat:@"highlight == YES"];
    [self dropStalledPresentations: self.highlights notMatchingPredicate: highlightPredicate];
    [self addNewPresentations:  self.highlights withPredicate: highlightPredicate];
	
	for (ACShellCollection *collection in self.collections) {
		[self dropStalledPresentations:collection.presentations notMatchingPredicate: nil];
	}
}

- (void)updateIndices: (NSMutableArray*) thePresentations {
    int i = 0;
    for (Presentation* presentation in thePresentations) {
        presentation.order = ++i;
    }
}

- (BOOL) hasLibrary {
    return [presentationData count] > 0;
}

- (NSString*) buildLibDir: (NSString*) libraryDir {
    return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent: libraryDir];
}

+ (NSString*) settingsFilepath {
    return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];
}

- (NSString*) subdirectoryFromTitle: (NSString*) aTitle {
    if ( ! ourNonDirNameCharSet ) {
        NSMutableCharacterSet * workingSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz01234567890"] mutableCopy];
        [workingSet addCharactersInString: @"_-."];
        [workingSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [workingSet invert];
        ourNonDirNameCharSet = [workingSet copy];
        [workingSet release];
    }
    NSString * str = [[[aTitle lowercaseString] componentsSeparatedByCharactersInSet: ourNonDirNameCharSet] componentsJoinedByString: @""];
    NSArray * words = [str componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [words componentsJoinedByString: @"_"];
}

@end
