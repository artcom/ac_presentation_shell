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
	NSMutableDictionary *presentationsData;
	NSMutableArray *allPresentations;
	
	
	NSString *directory;
}

@property (copy) NSString *directory;
@property (readonly) NSArray *allPresentations;

- (NSArray *)highlights;

- (PresentationData *)presentationDataWithId: (NSInteger)aId;
- (void)save;

- (NSString *)settingFilePath;

@end
