//
//  PresentationDataContext.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

@protocol PresentationDataContext <NSCoding, NSObject>

@property (readonly) NSString *libraryDirPath;

- (NSXMLElement*) xmlNode: (id) presentationId;
- (NSImage *)thumbnailForPresentation: (id) aId;

@end