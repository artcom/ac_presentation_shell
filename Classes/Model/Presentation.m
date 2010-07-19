//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationData.h"
#import "PresentationLibrary.h"

@interface Presentation ()

- (NSXMLElement*) xmlNode;

@end

@implementation Presentation

@synthesize selected;
@synthesize presentationId;
@synthesize index;
@synthesize context;

- (id)initWithId:(id)theId inContext: (PresentationLibrary *)theContext; {
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

- (NSString *)description {
	return [NSString stringWithFormat:@"%@", self.title];
}

- (NSImage *)thumbnail {
	if (thumbnail == nil) {
		NSString *filepath = [[PresentationLibrary libraryDir] stringByAppendingPathComponent: self.thumbnailPath];
		thumbnail =  [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];		
	}
	return thumbnail;
}


- (NSString*) title {     
    NSArray *titleNodes = [[self xmlNode] nodesForXPath:@"title" error:nil];
    if ([titleNodes count] != 1) {
        [NSException raise:@"No title attribute found in xml file" format:@""];
    } 
    
    return [[titleNodes objectAtIndex: 0] stringValue];	
}


- (BOOL)highlight {
	return [[[[self xmlNode] attributeForName:@"highlight"] objectValue] boolValue];
}

- (NSString *)thumbnailPath {
	NSArray *thumbnailNodes = [[self xmlNode] nodesForXPath:@"thumbnail" error:nil];
	if ([thumbnailNodes count] != 1) {
		[NSException raise:@"No thumbnail attribute found in xml file" format:@""];
	} 
	
	return [[thumbnailNodes objectAtIndex: 0] stringValue];	
}

- (NSString *)presentationPath {
	NSArray *nodes = [[self xmlNode] nodesForXPath:@"file" error:nil];
	if ([nodes count] != 1) {
		[NSException raise:@"No file property found in xml file" format:@""];
	} 
	
	return [[nodes objectAtIndex: 0] stringValue];	
}

- (NSString *)presentationFile {
	return [[PresentationLibrary libraryDir] stringByAppendingPathComponent: self.presentationPath];
}

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
	
	return self.presentationId == ((Presentation *)object).presentationId;
}


- (void) dealloc {
	[thumbnail release];
	[data release];
	[context release];
	[super dealloc];
}

- (NSXMLElement*) xmlNode {
    return [context xmlNode: presentationId];
}

@end
