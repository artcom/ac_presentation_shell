//
//  CATextLayer+Calculations.h
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CATextLayer (Calculations)

+ (CGSize)suggestedSizeForString:(NSAttributedString *)attrString constraints:(CGSize)constraints;
@end
