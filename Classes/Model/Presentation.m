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
@synthesize categories;

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
	return [NSString stringWithFormat:@"%ld-%@", (long)self.order, self.title];
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

- (NSNumber*) year {
    NSArray *yearNodes = [[self xmlNode] nodesForXPath:@"year" error:nil];
    if ([yearNodes count] == 0) {
        return nil;
    }
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    return [formatter numberFromString: [[yearNodes objectAtIndex: 0] stringValue]];
}

- (void) setYear:(NSNumber*) aYear {
    NSArray *yearNodes = [[self xmlNode] nodesForXPath:@"year" error:nil];
    NSXMLElement * yearNode = nil;
    if ([yearNodes count] == 0) {
        yearNode = [NSXMLElement elementWithName: @"year"];
        [[self xmlNode] addChild: yearNode];
    } else {
        yearNode = [yearNodes objectAtIndex: 0];
    }
    [yearNode setStringValue: [NSString stringWithFormat: @"%@", aYear]];	
}

- (NSString*) yearString {
    NSArray *yearNodes = [[self xmlNode] nodesForXPath:@"year" error:nil];
    if ([yearNodes count] == 0) {
        return @"";
    }
    return [[yearNodes objectAtIndex: 0] stringValue];	
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

- (NSArray *)categories {
    NSXMLNode *root = [[self.xmlNode nodesForXPath:@"categories" error:nil] firstObject];
    return [root.children valueForKeyPath:@"stringValue"];
}

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
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


- (NSXMLElement*) xmlNode {
	return [context xmlNodeForPresentation: presentationId];
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
