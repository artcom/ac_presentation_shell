//
//  CATextLayer+Calculations.m
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "CATextLayer+Calculations.h"

@implementation CATextLayer (Calculations)

+ (CGSize)suggestedSizeForString:(NSAttributedString *)attrString constraints:(CGSize)constraints
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attrString length]), NULL, constraints, NULL);
    CFRelease(framesetter);
    return fitSize;
}

@end
