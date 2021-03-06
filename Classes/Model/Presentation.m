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
@synthesize title;
@synthesize singleLineTitle;
@synthesize year;
@synthesize yearString;
@synthesize directory;
@synthesize presentationFilename;
@synthesize categories;

@synthesize selected;
@synthesize presentationId;
@synthesize order;
@synthesize context;
@synthesize thumbnail;
@synthesize thumbnailFilename;

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
    if (title == nil) {
        NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
        title = [[titleNodes objectAtIndex: 0] stringValue];
    }
    return title;
}

- (void) setTitle: (NSString*) newTitle {
    title = newTitle;
    NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
    [self willChangeValueForKey:@"singleLineTitle"];
    [[titleNodes objectAtIndex: 0] setStringValue: newTitle];	
    [self didChangeValueForKey:@"singleLineTitle"];
}

- (NSString*) singleLineTitle {
    if (singleLineTitle == nil) {
        singleLineTitle = [[self title] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    }
    return singleLineTitle;
}

- (BOOL)highlight {
    return [[[[self xmlNode] attributeForName:@"highlight"] objectValue] boolValue];
}

- (void) setHighlight:(BOOL) flag {
    [[[self xmlNode] attributeForName: @"highlight"] setStringValue:flag ? @"true" : @"false"];
}

- (NSNumber*) year {
    if (year == nil) {
        NSArray *yearNodes = [[self xmlNode] nodesForXPath:@"year" error:nil];
        if ([yearNodes count] > 0) {
            NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
            year = [formatter numberFromString: [[yearNodes objectAtIndex: 0] stringValue]];
        }
    }
    return year;
}

- (void) setYear:(NSNumber*) aYear {
    year = aYear;
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
    return self.year.stringValue;
}

- (NSString*) directory {
    if (directory == nil) {
        directory = [[[self xmlNode] attributeForName:@"directory"] stringValue];
    }
    return directory;
}

- (void) setDirectory:(NSString*) dir {
    directory = dir;
    [[[self xmlNode] attributeForName: @"directory"] setStringValue: dir];
}

- (NSString*) absoluteDirectory {
    return [[context libraryDirPath] stringByAppendingPathComponent: self.directory];
}

- (NSString *) thumbnailFilename {
    if (thumbnailFilename == nil) {
        NSArray *thumbnailNodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
        thumbnailFilename = [[thumbnailNodes objectAtIndex: 0] stringValue];
    }
    return thumbnailFilename;
}

- (void) setThumbnailFilename: (NSString*) newPath {
	[self willChangeValueForKey:@"thumbnail"];
    thumbnailFilename = newPath;
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
    if (presentationFilename == nil) {
        NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
        presentationFilename =  [[nodes objectAtIndex: 0] stringValue];
    }
    return presentationFilename;
}

- (void) setPresentationFilename: (NSString*) newPath {
    presentationFilename = newPath;
    NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
    [[nodes objectAtIndex: 0] setStringValue: newPath];
}

- (NSString*) relativePresentationPath {
    return [self.directory stringByAppendingPathComponent: self.presentationFilename];
}

- (NSString *)absolutePresentationPath {
    return [[context libraryDirPath] stringByAppendingPathComponent: self.relativePresentationPath];
}

- (void)setCategories:(NSArray *)theCategories
{
    categories = theCategories;
    [self willChangeValueForKey:@"categories"];
    NSArray *categoryNodes = [[self xmlNode] nodesForXPath:@"categories" error:nil];
    NSXMLElement *categoryNode = categoryNodes.lastObject;
    if (categoryNode == nil) {
        categoryNode = [NSXMLElement elementWithName: @"categories"];
        [[self xmlNode] addChild:categoryNode];
    }
    
    NSMutableArray *children = [NSMutableArray new];
    for (NSString *category in categories) {
        NSXMLElement *child = [NSXMLElement elementWithName: @"category"];
        [child setStringValue:category];
        [children addObject:child];
    }
    [categoryNode setChildren:children];
    [self didChangeValueForKey:@"categories"];
}

- (NSArray *)categories {
    if (categories == nil) {
        NSXMLNode *root = [[self.xmlNode nodesForXPath:@"categories" error:nil] lastObject];
        categories = [root.children valueForKeyPath:@"stringValue"];
    }
    return categories;
}

- (NSString *)categoriesTitles
{
    NSMutableArray *titles = [NSMutableArray new];
    for (LibraryCategory *category in self.context.categories) {
        if ([self.categories containsObject:category.ID]) {
            [titles addObject:category.title];
        }
    }
    return [titles componentsJoinedByString:@", "];
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
