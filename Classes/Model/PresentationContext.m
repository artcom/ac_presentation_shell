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
	[presentationsData release];
	[allPresentations release];
	
	[super dealloc];
}

- (NSArray *)allPresentations {
	if (allPresentations != nil) {
		return allPresentations;
	}
	
	allPresentations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];

	if (allPresentations != nil) {
		NSMutableArray *removedObjects = [[NSMutableArray alloc] init];
		[allPresentations enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
			Presentation *presentation = (Presentation *)object;
			
			presentation.context = self;
			NSNumber *presentationId = [NSNumber numberWithInt:presentation.presentationId];
			if (![presentationsData objectForKey: presentationId]) {
				[removedObjects addObject:presentation];
			}
		}];
		
		[allPresentations removeObjectsInArray:removedObjects];
	} else {
		allPresentations = [[NSMutableArray alloc] init];
		for (PresentationData *data in [presentationsData allValues]) {
			Presentation *presentation = [[[Presentation alloc] initWithId: data.presentationId inContext:self] autorelease];
			[allPresentations addObject:presentation];
		}
	}

	return allPresentations;
}

- (NSArray *)highlights {
	NSPredicate *highlightFilter = [NSPredicate predicateWithFormat:@"data.highlight == YES"];
	return [self.allPresentations filteredArrayUsingPredicate:highlightFilter];
}

- (PresentationData *)presentationDataWithId: (NSInteger)aId {
	return [presentationsData objectForKey:[NSNumber numberWithInt:aId]];
}

- (void)save {
	[NSKeyedArchiver archiveRootObject:allPresentations toFile:[self settingFilePath]];
}
						
- (NSString *)settingFilePath {
	return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"settings"];

}
					

@end
