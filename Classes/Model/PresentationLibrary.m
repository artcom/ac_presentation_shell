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

#define ACSHELL_SYNC_SUCCESSFUL @"syncSuccessful"

@interface PresentationLibrary ()

@property (readonly) NSMutableArray* allPresentations;
@property (readonly) NSMutableArray* highlights;
@property (readonly) NSMutableArray* collections;


+ (NSString*) settingsFilepath;

-(void) setup;
-(void) syncPresentations;
-(void) addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
-(void) dropStalledPresentations: (NSMutableArray*) thePresentations notMatchingPredicate: (NSPredicate *)thePredicate;
@end

@implementation PresentationLibrary
@synthesize library;
@synthesize syncSuccessful;
@synthesize libraryDirPath;

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
        [self.allPresentations addObjectsFromArray: [aDecoder decodeObjectForKey: ACSHELL_STR_LIBRARY]];
        [self.highlights addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_HIGHLIGHTS]];
        [self.collections addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_STR_COLLECTIONS]];
        
        self.syncSuccessful = [aDecoder decodeBoolForKey: ACSHELL_SYNC_SUCCESSFUL];
        
        [library assignContext: self];
    }

	return self;
}

-(void) setup {
	thumbnailCache = [[NSMutableDictionary alloc] init];
	
    presentationData = nil;
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

	[super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {	
	[aCoder encodeObject: self.allPresentations forKey:ACSHELL_STR_ALL];
	[aCoder encodeObject: self.highlights forKey:ACSHELL_STR_HIGHLIGHTS];
	[aCoder encodeObject: self.collections forKey:ACSHELL_STR_COLLECTIONS];
    [aCoder encodeBool: self.syncSuccessful forKey: ACSHELL_SYNC_SUCCESSFUL];
}

- (void)saveSettings {
	[NSKeyedArchiver archiveRootObject: self toFile:[PresentationLibrary settingsFilepath]];	
}

- (BOOL) loadXmlLibraryFromDirectory: (NSString*) directory {
    
	[self flushThumbnailCache];
	presentationData = nil;
    [libraryDirPath release];
    libraryDirPath = [directory retain];
    
    NSString *libraryPath = [directory stringByAppendingPathComponent:@"library.xml"];
    presentationData = [[NSMutableDictionary alloc] init];
    
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath: libraryPath]) {
        NSLog(@"file '%@' does not exist", libraryPath);
        return NO;
    }
    NSError *error = nil;
    NSXMLDocument *document = [[[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error] autorelease];
    NSArray *xmlPresentations = [document nodesForXPath:@"./presentations/presentation" error:&error];
    
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
    return YES;
}

- (void) saveXmlLibrary {
    NSXMLElement * root = [[[NSXMLElement alloc] initWithName: @"presentations"] autorelease];
    NSXMLDocument * document = [[[NSXMLDocument alloc] initWithRootElement: root] autorelease];
    for (id key in presentationData) {
        NSXMLElement * element = [presentationData objectForKey: key];
        [root addChild: element];
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

- (void) addPresentationWithTitle: (NSString*) title thumbnailPath: (NSString*) thumbnail 
                      keynotePath: (NSString*) keynote isHighlight: (BOOL) highlightFlag
                   copyController: (FileCopyController*) copyController
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
    
    Presentation * p = [[Presentation alloc] initWithId: newId inContext: self];
    [p updateWithTitle: title
         thumbnailPath: thumbnail
           keynotePath: keynote
           isHighlight: highlightFlag
        copyController: copyController];
    
    [self syncPresentations];
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
            Presentation * newPresentation = [[[Presentation alloc] initWithId: key inContext:self] autorelease];
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

- (void)updateIndices: (NSArray*) thePresentations {
    int i = 0;
    for (Presentation* presentation in thePresentations) {
        presentation.index = ++i;
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

@end
