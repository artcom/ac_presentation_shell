//
//  SingleLineTransformer.m
//  ACShell
//
//  Created by Robert Palmer on 19.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "SingleLineTransformer.h"


@implementation SingleLineTransformer

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue: (id) value {
	NSString *string = (NSString *)value;
    return [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}


@end
