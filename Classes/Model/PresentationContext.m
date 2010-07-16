//
//  PresentationContext.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationContext.h"
#import "PresentationData.h"
#import "Presentation.h"
#import "NSFileManager-DirectoryHelper.h"
#import "Settings.h"

@interface PresentationContext ()

- (void)ensureSettings;
- (void)updateIndices: (NSArray*) thePresentations;

@end

@implementation PresentationContext
@synthesize directory;

- (id)init {
	self = [super init];
	if (self != nil) {
		presentationsData = [[NSMutableDictionary alloc] init];

		self.directory = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"library"];
		NSString *libraryPath = [self.directory stringByAppendingPathComponent:@"library.xml"];
		#pragma mark TODO: check if file exists and offer option or hint for first sync.
		
		NSError *error = nil;
		NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:libraryPath] options:0 error:&error];
		NSArray *xmlPresentations = [document nodesForXPath:@"./presentations/presentation" error:&error];

		for (NSXMLElement *presentation in xmlPresentations) {
			PresentationData *data = [[PresentationData alloc] initWithXMLNode:presentation];
			[presentationsData setObject: data forKey: [NSNumber numberWithInt: [data presentationId]]];			
			
			[data release];
		}
	}
	
	return self;
}

- (void) dealloc {
	[directory release];
    [settings release];
	
	[super dealloc];
}

- (NSMutableArray *)allPresentations {
    [self ensureSettings];
	return settings.allPresentations;    
}

- (NSMutableArray *)highlights {
    [self ensureSettings];
	return settings.highlights;    
}

- (NSMutableArray *)presets {
	[self ensureSettings];

	return settings.presets;
}

- (PresentationData *)presentationDataWithId: (NSInteger)aId {
	return [presentationsData objectForKey:[NSNumber numberWithInt:aId]];
}

- (void)save {
    [NSKeyedArchiver archiveRootObject: settings toFile:[Settings filePath]];
}

- (void)ensureSettings {
    if (settings == nil) {
        settings = [[NSKeyedUnarchiver unarchiveObjectWithFile:[Settings filePath]] retain];
        if (settings == nil) {
            settings = [[[Settings alloc] init] retain];
        }
        [settings syncWithContext: self];
    }
}

#pragma mark TODO: move this to settings?
- (void) dropStalledPresentations: (NSMutableArray*) presentations {
    BOOL droppedStuff = NO;
    for (int i = [presentations count] - 1; i >= 0; i--) {
        Presentation* presentation = (Presentation*) [presentations objectAtIndex: i];
        if ([self presentationDataWithId: presentation.presentationId] == nil) {
            [presentations removeObjectAtIndex: i];
            droppedStuff = YES;
        }
    }
    if (droppedStuff) {
        [self updateIndices: presentations];
    }
}

- (void)syncPresentations: (NSMutableArray*) presentations withPredicate: thePredicate {
    [self dropStalledPresentations: presentations];
    NSMutableArray * presentIds = [[NSMutableArray alloc] init];
    for (Presentation* presentation in presentations) {
        [presentIds addObject: [NSNumber numberWithInt: presentation.presentationId]];
    }
    BOOL addedStuff = NO;
    for (NSNumber * key in presentationsData) {
        if (NSNotFound == [presentIds indexOfObject: key]) {
            Presentation * newPresentation = [[[Presentation alloc] initWithId: [key integerValue] inContext:self] autorelease];
            if (thePredicate == nil || [thePredicate evaluateWithObject:newPresentation]) {
                [presentations insertObject: newPresentation atIndex:0];
                addedStuff = YES;
            }
        } else {
            ((Presentation*)[presentations objectAtIndex: [presentIds indexOfObject: key]]).context = self;
        }
    }
    if (addedStuff) {
        [self updateIndices: presentations];
    }
}

- (void)updateIndices: (NSArray*) thePresentations {
    int i = 0;
    for (Presentation* presentation in thePresentations) {
        presentation.index = ++i;
    }
}
@end
