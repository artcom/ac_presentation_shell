//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationLibrary.h"
#import "PresentationData.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"
#import "Settings.h"

#define ACSHELL_LIBRARY_NAME @"LIBRARY"
#define ACSHELL_COLLECTIONS @"COLLECTIONS"
#define ACSHELL_CATEGORY_ALL @"All"
#define ACSHELL_CATEGORY_HIGHLIGHTS @"Highlights"

@interface PresentationLibrary ()

-(void) setup;
-(void) syncPresentations;

@end

@implementation PresentationLibrary
@synthesize libraryRoot;

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

        [libraryRoot assignContext: self];
    }
	
	return self;
}

-(void) setup {
    NSLog(@"setup");
    presentationData = nil;
    libraryRoot = [[ACShellCollection collectionWithName: @"root"] retain];
    ACShellCollection *library = [[ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_LIBRARY_NAME, nil)] retain];
    [libraryRoot.children addObject: library];
    
    ACShellCollection *all = [[ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_CATEGORY_ALL, nil)] retain];
    [library.children addObject: all];
    ACShellCollection *highlights = [[ACShellCollection collectionWithName: NSLocalizedString(ACSHELL_CATEGORY_HIGHLIGHTS, nil)] retain];
    [library.children addObject: highlights];
    
    ACShellCollection *collections = [[ACShellCollection collectionWithName: NSLocalizedString( ACSHELL_COLLECTIONS, nil)] retain];
    [libraryRoot.children addObject: collections];
}

- (void) dealloc {
    
	[super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {	
	[aCoder encodeObject: self.allPresentations forKey:@"allPresentations"];
	[aCoder encodeObject: self.highlights forKey:@"highlights"];
	[aCoder encodeObject: self.collections forKey:@"collections"];	
}

- (NSXMLElement *) xmlNode: (id)aId {
    if (presentationData != nil) {
        return [presentationData objectForKey: aId];
    }
    return nil;
}

+ (id) contextFromSettingsFile {
    PresentationLibrary * lib = [NSKeyedUnarchiver unarchiveObjectWithFile: [PresentationLibrary settingsFilepath]];
    if (lib != nil) {
        return [lib retain];
    }
    NSLog(@"no library");
    return [[PresentationLibrary alloc] init];
}

- (void)saveSettings {
    [NSKeyedArchiver archiveRootObject: self toFile:[PresentationLibrary settingsFilepath]];
}

- (NSMutableArray*) allPresentations {
    return (NSMutableArray*)[[[libraryRoot.children objectAtIndex: 0] objectAtIndex: 0] children];
}

- (NSMutableArray*) highlights {
    return (NSMutableArray*)[[[libraryRoot.children objectAtIndex: 0] objectAtIndex: 1] children];
}

- (NSMutableArray*) collections {
    return (NSMutableArray*)[[libraryRoot.children objectAtIndex: 1] children];
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
    NSMutableArray * presentIds = [[NSMutableArray alloc] init];
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
        } else {
            ((Presentation*)[thePresentations objectAtIndex: [presentIds indexOfObject: key]]).context = self;
        }
    }
    if (addedStuff) {
        [self updateIndices: thePresentations];
    }
}

-(void) syncPresentations {
    NSLog(@"sync");
    
    [self dropStalledPresentations: self.allPresentations];
    [self addNewPresentations: self.allPresentations withPredicate: nil];
    [self dropStalledPresentations: self.highlights];
    [self addNewPresentations:  self.highlights withPredicate: [NSPredicate predicateWithFormat:@"data.highlight == YES"]];
	
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

- (BOOL) loadXmlLibrary {
    NSLog(@"loadXML");
    presentationData = nil;

    NSString *libraryPath = [[PresentationLibrary libraryDir] stringByAppendingPathComponent:@"library.xml"];
    
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath: libraryPath]) {
        NSLog(@"file '%@' does not exist", libraryPath);
        return NO;
    }
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error];
    NSArray *xmlPresentations = [document nodesForXPath:@"./presentations/presentation" error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to load xml library '%@': %@", libraryPath, error);
        return NO;
    }

    presentationData = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSXMLElement * element in xmlPresentations) {
        [presentationData setObject: element forKey: [[element attributeForName:@"id"] objectValue]];
    }
    
    [self syncPresentations];
    return YES;
}

- (BOOL) hasLibrary {
    return presentationData != nil;
}

+ (NSString*) libraryDir {
    return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"library"];
}

+ (NSString*) settingsFilepath {
    return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];
}

@end
