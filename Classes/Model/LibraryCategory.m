//
//  Category.m
//  ACShell
//
//  Created by Julian Krumow on 01.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "LibraryCategory.h"
#import "PresentationLibrary.h"

@implementation LibraryCategory

- (instancetype)initWithId:(NSString *)ID inContext:(PresentationLibrary *)context
{
    self = [super init];
    if (self) {
        _ID = ID.copy;
        _index = @(ID.integerValue);
        _context = context;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _ID = [aDecoder decodeObjectForKey:@"ID"];
        _index = @(_ID.integerValue);
        _context = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithId:self.ID inContext:self.context];
}

- (NSXMLElement*) xmlNode
{
    return [self.context xmlNodeForCategory:self.ID];
}

- (NSString *)title
{
    return [[self xmlNode] attributeForName:@"title"].stringValue;
}

- (NSString *)directory
{
    return [[self xmlNode] attributeForName:@"directory"].stringValue;
}

- (NSString *)directoryPath
{
    return [[self.context.libraryDirPath stringByAppendingPathComponent:self.context.categoriesDirectory]
            stringByAppendingPathComponent:self.directory];
}

- (NSArray *)backgroundImages
{
    NSXMLNode *assets = [[self xmlNode] nodesForXPath:@"assets" error:nil].firstObject;
    return [[assets nodesForXPath:@"background" error:nil] valueForKey:@"stringValue"];
}

- (NSArray *)backgroundImagePaths
{
    return [[self directoryPath] stringsByAppendingPaths:self.backgroundImages];
}

@end
