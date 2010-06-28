//
//  Presentation.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Presentation.h"


@implementation Presentation

@synthesize selected;
@synthesize presentationId;

+ (Presentation *)presentationWithId: (NSInteger)aPresentationId {
	Presentation *presenation = [[Presentation alloc] init];
	presenation.presentationId = aPresentationId;
	
	return [presenation autorelease];
}

@end
