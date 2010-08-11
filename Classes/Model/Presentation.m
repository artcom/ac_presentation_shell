//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationLibrary.h"

@implementation Presentation
@synthesize selected;
@synthesize presentationId;
@synthesize order;
@synthesize context;
@synthesize thumbnailFilename;
@synthesize title;

- (id)initWithId:(id)theId inContext: (PresentationLibrary*) theContext {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.context = theContext;
		self.presentationId = theId;
        self.order = -1;
	}
	
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self != nil) {
		self.selected = [aDecoder decodeBoolForKey:@"selected"];
		self.presentationId = [aDecoder decodeObjectForKey:@"presentationId"];
        if ([aDecoder containsValueForKey: @"index"]) {
            self.order = [aDecoder decodeIntegerForKey:@"index"];
        } else {
            self.order = [aDecoder decodeIntegerForKey:@"order"];
        }
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
	[aCoder encodeInteger:self.order forKey:@"order"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%d-%@", self.order, self.title];
}

- (NSImage *)thumbnail {
	return [context thumbnailForPresentation:self];
}

- (NSString*) title {     	
    NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
    return [[titleNodes objectAtIndex: 0] stringValue];	
}

- (void) setTitle: (NSString*) newTitle {
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

- (NSString*) directory {
	return [[[self xmlNode] attributeForName:@"directory"] stringValue];
}

- (void) setDirectory:(NSString*) dir {
    [[[self xmlNode] attributeForName: @"directory"] setStringValue: dir];
}

- (NSString*) absoluteDirectory {
    return [[context libraryDirPath] stringByAppendingPathComponent: self.directory];
}

- (NSString *) thumbnailFilename {
	NSArray *thumbnailNodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
	return [[thumbnailNodes objectAtIndex: 0] stringValue];	
}

- (void) setThumbnailFilename: (NSString*) newPath {
	[self willChangeValueForKey:@"thumbnail"];
	[thumbnail release];
	thumbnail = nil;
    NSArray *nodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
    [[nodes objectAtIndex: 0] setStringValue: newPath];
	[self didChangeValueForKey:@"thumbnail"];
}

- (NSString *)relativeThumbnailPath {
	return [self.directory stringByAppendingPathComponent: self.thumbnailFilename];	
}

- (NSString*) absoluteThumbnailPath {
    return [[context libraryDirPath] stringByAppendingPathComponent: self.relativeThumbnailPath];
}


- (NSString *) presentationFilename {
	NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
	return [[nodes objectAtIndex: 0] stringValue];	
}

- (void) setPresentationFilename: (NSString*) newPath {
    NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
    [[nodes objectAtIndex: 0] setStringValue: newPath];
}

- (NSString*) relativePresentationPath {
    return [self.directory stringByAppendingPathComponent: self.presentationFilename];
}

- (NSString *)absolutePresentationPath {
	return [[context libraryDirPath] stringByAppendingPathComponent: self.relativePresentationPath];
}

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
        NSLog(@"=== class mismatch");
		return NO;
	}
    NSLog(@"match: %d", [self.presentationId isEqual: ((Presentation *)object).presentationId]);
    return [self.presentationId isEqual: ((Presentation *)object).presentationId];
}

- (BOOL)isComplete {
	return self.presentationFileExists && self.thumbnailFileExists;
}

- (BOOL) presentationFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath: self.absolutePresentationPath];
}

- (BOOL) thumbnailFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath: self.absoluteThumbnailPath];
}

- (void) dealloc {
	[thumbnail release];
	[context release];
	[super dealloc];
}

- (NSXMLElement*) xmlNode {
	return [context xmlNode: presentationId];
}

- (NSComparisonResult) compareByOrder: (Presentation*) other {
    if (self.order < other.order) {
        return NSOrderedAscending;
    } else if (self.order > other.order) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}
@end
