//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationLibrary.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"

#define ACSHELL_LIBRARY_NAME @"LIBRARY"
#define ACSHELL_COLLECTIONS @"COLLECTIONS"
#define ACSHELL_CATEGORY_ALL @"All"
#define ACSHELL_CATEGORY_HIGHLIGHTS @"Highlights"

@interface PresentationLibrary ()

@property (readonly) NSMutableArray* allPresentations;
@property (readonly) NSMutableArray* highlights;
@property (readonly) NSMutableArray* collections;

+ (NSString*) settingsFilepath;

-(void) setup;
-(void) syncPresentations;
-(void) addNewPresentations: (NSMutableArray*) presentations withPredicate: (NSPredicate*) thePredicate;
-(void) dropStalledPresentations: (NSMutableArray*) presentations;

@end

@implementation PresentationLibrary
@synthesize library;
@synthesize libraryDirPath;

+ (id) libraryFromSettingsFile {
    PresentationLibrary * lib = [NSKeyedUnarchiver unarchiveObjectWithFile: [PresentationLibrary settingsFilepath]];
    if (lib != nil) {
        return lib;
    }
    NSLog(@"no settings file");
    return [[[PresentationLibrary alloc] init] autorelease];
}

-(id) init {
	self = [super init];
	if (self != nil) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
        [self setup];
        [self.allPresentations addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_CATEGORY_ALL]];
        [self.highlights addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_CATEGORY_HIGHLIGHTS]];
        [self.collections addObjectsFromArray: [aDecoder decodeObjectForKey:ACSHELL_COLLECTIONS]];

        [library assignContext: self];
    }

	return self;
}

-(void) setup {
    presentationData = nil;
    library = [[ACShellCollection collectionWithName: @"root"] retain];
    ACShellCollection *lib = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_LIBRARY_NAME, nil)];
    [library.children addObject: lib];
    
    ACShellCollection *all = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_CATEGORY_ALL, nil)];
    [lib.children addObject: all];
    ACShellCollection *highlights = [ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_CATEGORY_HIGHLIGHTS, nil)];
    [lib.children addObject: highlights];
    
    ACShellCollection *collections = [ACShellCollection collectionWithName: NSLocalizedString( ACSHELL_COLLECTIONS, nil)];
    [library.children addObject: collections];
}

- (void) dealloc {
    [presentationData release];
	[library release];

	[super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {	
	[aCoder encodeObject: self.allPresentations forKey:ACSHELL_CATEGORY_ALL];
	[aCoder encodeObject: self.highlights forKey:ACSHELL_CATEGORY_HIGHLIGHTS];
	[aCoder encodeObject: self.collections forKey:ACSHELL_COLLECTIONS];	
}

- (void)saveSettings {
	[NSKeyedArchiver archiveRootObject: self toFile:[PresentationLibrary settingsFilepath]];	
}

- (BOOL) loadXmlLibraryFromDirectory: (NSString*) directory {
    NSLog(@"loadXML");
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
    }
    
    [self syncPresentations];
    return YES;
}

- (NSXMLElement *) xmlNode: (id)aId {
	if ([self hasLibrary]) {
        return [presentationData objectForKey: aId];
    }
    return nil;
}

- (NSUInteger)collectionCount {
	return [self.collections count];
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

- (void) dropStalledPresentations: (NSMutableArray*) thePresentations {
    BOOL droppedStuff = NO;
    for (int i = [thePresentations count] - 1; i >= 0; i--) {
        Presentation* presentation = (Presentation*) [thePresentations objectAtIndex: i];
        if ([self xmlNode: presentation.presentationId] == nil) {
            [thePresentations removeObjectAtIndex: i];
            droppedStuff = YES;
        }
    }
    if (droppedStuff) {
        [self updateIndices: thePresentations];
    }
}

- (void)addNewPresentations: (NSMutableArray*) thePresentations withPredicate: thePredicate {
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
    [self dropStalledPresentations: self.allPresentations];
    [self addNewPresentations: self.allPresentations withPredicate: nil];
    [self dropStalledPresentations: self.highlights];
    [self addNewPresentations:  self.highlights withPredicate: [NSPredicate predicateWithFormat:@"highlight == YES"]];
	
	for (ACShellCollection *collection in self.collections) {
		[self dropStalledPresentations:collection.presentations];
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
