//
//  PresentationContext.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationData;


@interface PresentationContext : NSObject {
	NSMutableDictionary *presentations;
}

- (NSArray *)allPresentations;
- (PresentationData *)presentationDataWithId: (NSInteger)aId;


@end
