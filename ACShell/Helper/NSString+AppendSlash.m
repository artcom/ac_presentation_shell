//
//  NSString+AppendSlash.m
//  ACShell
//
//  Created by Julian Krumow on 09.04.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import "NSString+AppendSlash.h"

@implementation NSString (AppendSlash)
- (NSString*) stringByAppendingSlash {
    if ([self characterAtIndex:self.length - 1] != '/') {
        return [self stringByAppendingString:@"/"];
    }
    return self;
}
@end
