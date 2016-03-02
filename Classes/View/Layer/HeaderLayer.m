//
//  HeaderLayer.m
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "HeaderLayer.h"
#import "CATextLayer+Calculations.h"

@interface HeaderLayer ()
@property (nonatomic, strong) CATextLayer *titleLayer;
@end

@implementation HeaderLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupLayers];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title attributes:nil];
    [self setNeedsLayout];
}

- (void)setupLayers
{
    self.titleLayer = [CATextLayer layer];
    [self addSublayer:self.titleLayer];
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height);
}

@end
