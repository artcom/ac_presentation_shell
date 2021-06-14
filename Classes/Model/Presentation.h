//
//  Presentation.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"

@class PresentationLibrary;
@class FileCopyController;

@interface Presentation : NSObject <NSCoding, NSCopying>
@property (assign) BOOL selected;
@property (assign) NSInteger order;
@property (strong) id presentationId;
@property (strong) PresentationLibrary* context;

@property (strong) NSString *title;
@property (weak, readonly) NSString *singleLineTitle;

@property (assign) BOOL highlight;
@property (strong) NSNumber* year;
@property (strong, readonly) NSString *yearString;

@property (strong)   NSString * directory;
@property (weak, readonly) NSString * absoluteDirectory;

@property (strong) NSArray *categories;
@property (weak, readonly) NSString *categoriesTitles;

@property (strong)   NSString * thumbnailFilename;
@property (weak, readonly) NSString * relativeThumbnailPath;
@property (weak, readonly) NSString * absoluteThumbnailPath;

@property (strong)   NSString * presentationFilename;
@property (weak, readonly) NSString * relativePresentationPath;
@property (weak, readonly) NSString * absolutePresentationPath;

@property (readonly) BOOL presentationFileExists;
@property (readonly) BOOL thumbnailFileExists;

@property (weak, readonly) NSImage *thumbnail;
@property (readonly) BOOL isComplete;

- (id) initWithId:(id)theId inContext: (PresentationLibrary*)theContext;

- (NSXMLElement*) xmlNode;

- (NSComparisonResult) compareByOrder: (Presentation*) other;
- (BOOL) isEqual: (id) object;
@end
