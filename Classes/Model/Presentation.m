//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "Presentation.h"
#import "PresentationLibrary.h"
#import "FileCopyController.h"


static NSCharacterSet * ourNonDirNameCharSet;

@interface Presentation ()

- (NSString*) subdirectoryFromTitle: (NSString*) title;

- (void) setTitle: (NSString*) title;

- (BOOL) updateSubdirectory: (NSString*) newSubdirectory;
- (BOOL) updateThumbnail: (NSString*) newThumbnailPath;
- (BOOL) updateKeynote: (NSString*) newKeynotePath;
- (BOOL) updateFile: (NSString*) oldFile new: (NSString*) newFile;

- (BOOL)prepareCopyFrom: (NSString *)oldFile to: (NSString *)newFile;

@end

@implementation Presentation
@synthesize selected;
@synthesize presentationId;
@synthesize index;
@synthesize context;
@synthesize thumbnailFilename;
//@synthesize presentationFilename;

- (id)initWithId:(id)theId inContext: (PresentationLibrary*) theContext {
	self = [super init];
	if (self != nil) {
		self.selected = YES;
		self.context = theContext;
		self.presentationId = theId;
        self.index = -1;
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

- (BOOL) updateWithTitle: (NSString*) title
           thumbnailPath: (NSString*) thumbnailPath
             keynotePath: (NSString*) keynotePath
             isHighlight: (BOOL) highlightFlag
          copyController: (FileCopyController *)controller
{
	[copyController release];
	copyController = [controller retain];
	
    BOOL xmlChanged = NO;
    if ([self updateSubdirectory: [self subdirectoryFromTitle: title]]) {
        xmlChanged = YES;
    }
    if ([self updateThumbnail: thumbnailPath]) {
        xmlChanged = YES;
    }
    if ([self updateKeynote: keynotePath]) {
        xmlChanged = YES;
    }
    if ( ! [self.title isEqual: title]) {
        self.title = title;
        xmlChanged = YES;
    }
    if (self.highlight != highlightFlag) {
        self.highlight = highlightFlag;
        xmlChanged = YES;
    }

    if (xmlChanged) {
		[context saveXmlLibrary];
	}
	[context syncPresentations];
	[context flushThumbnailCacheForPresentation: self];
    
    return xmlChanged;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@", self.title];
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
		return NO;
	}
	
	return self.presentationId == ((Presentation *)object).presentationId;
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


- (NSString*) subdirectoryFromTitle: (NSString*) aTitle {
    if ( ! ourNonDirNameCharSet ) {
        NSMutableCharacterSet * workingSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [workingSet addCharactersInString: @"_-."];
        [workingSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [workingSet invert];
        ourNonDirNameCharSet = [workingSet copy];
    }
    NSString * str = [[[aTitle componentsSeparatedByCharactersInSet: ourNonDirNameCharSet] componentsJoinedByString: @""] autorelease];
    NSArray * words = [[str componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] autorelease];
    return [[words componentsJoinedByString: @"_"] lowercaseString];
}

- (void) dealloc {
	[thumbnail release];
	[context release];
	[super dealloc];
}

- (NSXMLElement*) xmlNode {
	return [context xmlNode: presentationId];
}

- (BOOL) updateSubdirectory: (NSString*) newSubdirectory {
    if ([self.directory isEqual: newSubdirectory]) {
        return NO;
    }
    
    NSError * error;
    NSString * newDir = [[context libraryDirPath] stringByAppendingPathComponent: newSubdirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath: newDir]) {
        NSLog(@"Conflicting directory names");
        [NSException raise: @"Conflict"
                    format: @"Directory '%@' already exists.", newSubdirectory];
    }
    if ([self.directory length] == 0) {
        self.directory = newSubdirectory;
        if ( ! [[NSFileManager defaultManager] createDirectoryAtPath: self.absoluteDirectory
                                         withIntermediateDirectories: YES attributes: nil error: &error])
        {
            NSLog(@"Failed to create directory: %@", error);
            [NSException raise: @"IO Error"
                        format: @"Failed to create directory: %@", error];            
        }
    } else {
        NSString * oldDir = self.absoluteDirectory;
        if ( ! [[NSFileManager defaultManager] moveItemAtPath: oldDir toPath: newDir error: &error]) {
            NSLog(@"Failed to rename directory: %@", error);
            [NSException raise: @"IO Error"
                        format: @"Failed to rename directory: %@", error];
        }
        self.directory = newSubdirectory;
    }
    return YES;
}

- (BOOL) updateThumbnail: (NSString*) newThumbnailPath {
    if ( ! [self updateFile: self.absoluteThumbnailPath new: newThumbnailPath]) {
        return NO;
    }
    self.thumbnailFilename = [newThumbnailPath lastPathComponent];
    return YES;
}

- (BOOL) updateKeynote: (NSString*) newKeynotePath {
    if (![self prepareCopyFrom: self.absolutePresentationPath to: newKeynotePath]) {
		return NO;
	}
	
    NSString * p = self.absolutePresentationPath;
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: p isDirectory: &isDir];
    if (exists && isDir) {
        p = [p stringByAppendingPathComponent: [newKeynotePath lastPathComponent]];
        
    }
    
    [copyController copy: newKeynotePath to: p];
	
    self.presentationFilename = [newKeynotePath lastPathComponent];
    return YES;
}


- (BOOL) updateFile: (NSString*) oldFile new: (NSString*) newFile {
    if (![self prepareCopyFrom:oldFile to:newFile]) {
		return NO;
	}
	
    NSString * newTargetPath = [self.absoluteDirectory stringByAppendingPathComponent: [newFile lastPathComponent]];
    NSError * error;
    if ( ! [[NSFileManager defaultManager] copyItemAtPath: newFile toPath: newTargetPath error: &error]) {
        [NSException raise: @"IO Error" format: @"Failed to copy thumbnail: %@", error];
    }
    return YES;
}

- (BOOL)prepareCopyFrom: (NSString *)oldFile to: (NSString *)newFile {
	if (newFile == nil) {
        return NO;
    }
    if ([newFile isEqual: oldFile]) {
        return NO;
    }
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager]  fileExistsAtPath: oldFile isDirectory: &isDirectory];
    // XXX bug: keynotes might be a directory!!!
    if (exists && ! isDirectory) {
        NSError * error;
        if ( ! [[NSFileManager defaultManager] removeItemAtPath: oldFile error: &error]) {
            [NSException raise: @"IO Error" format: @"Failed to remove old file: %@", error];
        }
    }
	
	return YES;
}



@end
