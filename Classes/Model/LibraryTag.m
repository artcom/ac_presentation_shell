//
//  LibraryTag.m
//  ACShell
//
//  Created by Julian Krumow on 08.12.22.
//  Copyright © 2022 ART+COM AG. All rights reserved.
//

#import "LibraryTag.h"
#import "PresentationLibrary.h"

@implementation LibraryTag

- (instancetype)initWithId:(NSString *)ID inContext:(PresentationLibrary *)context
{
    self = [super init];
    if (self) {
        _ID = ID.copy;
        _context = context;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    self = [super init];
    if (self) {
        _ID = [coder decodeObjectForKey:@"ID"];
        _context = nil;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.ID forKey:@"ID"];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithId:self.ID inContext:self.context];
}

- (NSXMLElement*) xmlNode
{
    return [self.context xmlNodeForTag:self.ID];
}

- (NSString *)title
{
    return [[self xmlNode] attributeForName:@"title"].stringValue;
}


@end
