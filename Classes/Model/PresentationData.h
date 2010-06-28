//
//  PresentationData.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PresentationData : NSObject {
	NSXMLElement *xmlNode;
}

@property (readonly) NSInteger presentationId;
@property (readonly) NSString *title;
@property (readonly) BOOL highlight;
//@property (readonly) NSString *thumbnailPath;
//@property (readonly) NSString *filetype;
//@property (readonly) NSString *presentationPath;

- (id)initWithXMLNode: (NSXMLElement *)aNode;

@end
