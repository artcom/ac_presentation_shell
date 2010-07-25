//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationLibrary.h"


static NSCharacterSet * ourNonDirNameCharSet;

@interface Presentation ()

- (NSString*) subdirectoryFromTitle;
- (NSString*) extractSubdirectoryFromPresentationPath;

- (void) setPresentationPath: (NSString*) newPath;
- (void) setThumbnailPath: (NSString*) newPath;
- (void) setTitle: (NSString*) title;

- (BOOL) updateSubdirectory: (NSString*) newSubdirectory;
- (BOOL) updateThumbnail: (NSString*) newThumbnailPath;
- (NSString*) rewriteToplevelDirectory: (NSString*) path toDir: (NSString*) newToplevel;

@end

@implementation Presentation

@synthesize selected;
@synthesize presentationId;
@synthesize index;
@synthesize context;

- (id)initWithId:(id)theId inContext: (id<PresentationDataContext>) theContext {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.context = theContext;
		self.presentationId = theId;
        self.index = -1;
		
		[self thumbnail];
	}
	
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.selected = [aDecoder decodeBoolForKey:@"selected"];
		self.presentationId = [aDecoder decodeObjectForKey:@"presentationId"];
        self.index = [aDecoder decodeIntegerForKey:@"index"];
		self.context = nil;
	}	
	return self;
}

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithId:self.presentationId inContext:self.context];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:self.selected forKey:@"selected"];
	[aCoder encodeObject:self.presentationId forKey:@"presentationId"];
	[aCoder encodeInteger:self.index forKey:@"index"];
}

- (BOOL) updateFromPresentation: (Presentation*) other newThumbnailPath: (NSString*) filename {
    NSLog(@"subdir: '%@'", [other subdirectoryFromTitle]);
    BOOL xmlChanged = NO;
    if ([self updateSubdirectory: [other subdirectoryFromTitle]]) {
        xmlChanged = YES;
    }
    if ( ! [self.title isEqual: other.title]) {
        self.title = other.title;
        xmlChanged = YES;
    }
    if (self.highlight != other.highlight) {
        self.highlight = other.highlight;
        xmlChanged = YES;
    }
    if ([self updateThumbnail: filename]) {
        xmlChanged = YES;
    }
    return xmlChanged;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@", self.title];
}

- (NSImage *)thumbnail {
	if (thumbnail == nil) {
		NSString *filepath = [[context libraryDirPath] stringByAppendingPathComponent: self.thumbnailPath];
		thumbnail =  [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];		
	}
	return thumbnail;
}

- (NSString*) title {     	
    NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
    return [[titleNodes objectAtIndex: 0] stringValue];	
}

- (void) setTitle: (NSString*) newTitle {
    NSLog(@"setTitle: %@", newTitle);
    NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
    [self willChangeValueForKey:@"singleLineTitle"];
    [[titleNodes objectAtIndex: 0] setStringValue: newTitle];	
    [self didChangeValueForKey:@"singleLineTitle"];
}

- (NSString*) singleLineTitle {
	return [[self title] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]; 
}


- (BOOL)highlight {
	return [[[[self xmlNode] attributeForName:@"highlight"] objectValue] boolValue];
}

- (void) setHighlight:(BOOL) flag {
    [[[self xmlNode] attributeForName: @"highlight"] setStringValue: flag ? @"true" : @"false"];
}


- (NSString *)thumbnailPath {
	NSArray *thumbnailNodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
	return [[thumbnailNodes objectAtIndex: 0] stringValue];	
}

- (void) setThumbnailPath: (NSString*) newPath {
    NSArray *nodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
    [[nodes objectAtIndex: 0] setStringValue: newPath];
}

- (NSString *)presentationPath {
	NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
	return [[nodes objectAtIndex: 0] stringValue];	
}

- (void) setPresentationPath: (NSString*) newPath {
    NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
    [[nodes objectAtIndex: 0] setStringValue: newPath];
}


- (NSString *)presentationFile {
	return [[context libraryDirPath] stringByAppendingPathComponent: self.presentationPath];
}

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
	
	return self.presentationId == ((Presentation *)object).presentationId;
}

- (BOOL)isComplete {
	return self.presentationFileExists && self.thumbnail != nil;
}

- (BOOL) presentationFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath: self.presentationFile];
}

- (NSString*) subdirectoryFromTitle {
    if ( ! ourNonDirNameCharSet ) {
        NSMutableCharacterSet * workingSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [workingSet addCharactersInString: @"_-."];
        [workingSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [workingSet invert];
        ourNonDirNameCharSet = [workingSet copy];
    }
    NSString * str = [[[self.title componentsSeparatedByCharactersInSet: ourNonDirNameCharSet] componentsJoinedByString: @""] autorelease];
    NSArray * words = [[str componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] autorelease];
    str = [words componentsJoinedByString: @"_"];
    return str;
}

- (void) dealloc {
	[thumbnail release];
	[context release];
	[super dealloc];
}

- (NSXMLElement*) xmlNode {
	NSXMLElement *node = [context xmlNode: presentationId];
	if (node == nil) {
        NSLog(@"node is nil, not good");
		// [NSException raise:@"No title attribute found in xml file" format:@""];
    } 
	
    return node;
}

- (NSString*) rewriteToplevelDirectory: (NSString*) path toDir: (NSString*) newToplevel {
    NSMutableArray * components = [[path pathComponents] mutableCopy];
    [components replaceObjectAtIndex: 0 withObject: newToplevel];
    return [NSString pathWithComponents: components];
}

- (NSString*) extractSubdirectoryFromPresentationPath {
    return [[self.presentationPath pathComponents] objectAtIndex: 0];
}

- (BOOL) updateSubdirectory: (NSString*) newSubdirectory {
    if ([[self extractSubdirectoryFromPresentationPath] isEqual: newSubdirectory]) {
        return NO;
    }

    NSLog(@"directory changed");
    NSString * newDir = [[context libraryDirPath] stringByAppendingPathComponent: newSubdirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath: newDir]) {
        NSLog(@"Conflicting directory names");
        [NSException raise: @"Conflict"
                    format: @"Directory '%@' already exists.", newSubdirectory];
    }
    NSString * oldDir = [[context libraryDirPath] stringByAppendingPathComponent: [self extractSubdirectoryFromPresentationPath]];
    NSError * error;
    if ( ! [[NSFileManager defaultManager] moveItemAtPath: oldDir toPath: newDir error: &error]) {
        NSLog(@"Failed to rename directory: %@", error);
        [NSException raise: @"IO Error"
                    format: @"Failed o rename directory: %@", error];
    }
    self.presentationPath = [self rewriteToplevelDirectory: self.presentationPath toDir: newSubdirectory];
    self.thumbnailPath = [self rewriteToplevelDirectory: self.thumbnailPath toDir: newSubdirectory];
    return YES;
}

- (BOOL) updateThumbnail: (NSString*) newThumbnailPath {
    if (newThumbnailPath == nil) {
        return NO;
    }
    if ([newThumbnailPath isEqual: self.thumbnailPath]) {
        return NO;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath: self.thumbnailPath]) {
        NSError * error;
        if ( ! [[NSFileManager defaultManager] removeItemAtPath: self.thumbnailPath error: &error]) {
            [NSException raise: @"IO Error" format: @"Failed to remove thumbnail: %@", error];
        }
    }
    NSString * subdir = [self extractSubdirectoryFromPresentationPath];
    NSString * newPath = [[context.libraryDirPath 
                           stringByAppendingPathComponent: subdir]
                          stringByAppendingPathComponent: [newThumbnailPath lastPathComponent]];
    NSError * error;
    if ( ! [[NSFileManager defaultManager] copyItemAtPath: newThumbnailPath toPath: newPath error: &error]) {
        [NSException raise: @"IO Error" format: @"Failed to copy thumbnail: %@", error];
    }
    self.thumbnailPath = [subdir stringByAppendingPathComponent: [newThumbnailPath lastPathComponent]];
    return YES;
}
@end
