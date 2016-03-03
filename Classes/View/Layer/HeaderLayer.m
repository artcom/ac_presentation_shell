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
@property (nonatomic, strong) NSDictionary *lightFontAttributes;
@property (nonatomic, strong) NSDictionary *darkFontAttributes;
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

- (void)setupLayers
{
    self.backgroundColor = [NSColor whiteColor].CGColor;
    self.titleLayer = [CATextLayer layer];
    self.bottomEdgeLayer = [CALayer layer];
    self.bottomEdgeLayer.backgroundColor = [NSColor whiteColor].CGColor;
    [self addSublayer:self.titleLayer];
    [self addSublayer:self.bottomEdgeLayer];
}

- (NSColor *)lightColor
{
    return [NSColor colorWithCalibratedRed:0.5725 green:0.5725 blue:0.5725 alpha:1.0];
}

- (NSColor *)darkColor
{
    return [NSColor colorWithCalibratedRed:0.1372 green:0.1372 blue:0.1372 alpha:1.0];
}

- (NSDictionary *)lightFontAttributes
{
    if (_lightFontAttributes == nil) {
        NSFont *font = [NSFont fontWithName:@"ACSwiss" size:13.0f];
        _lightFontAttributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName:self.lightColor};
    }
    return _lightFontAttributes;
}

- (NSDictionary *)darkFontAttributes
{
    if (_darkFontAttributes == nil) {
        NSFont *font = [NSFont fontWithName:@"ACSwiss" size:13.0f];
        _darkFontAttributes = @{NSFontAttributeName:font,
                                NSForegroundColorAttributeName:self.darkColor};
    }
    return _darkFontAttributes;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setLightTitle:title];
}

- (void)setLightTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.lightFontAttributes];
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(3.0, 3.0, size.width, size.height);
    [self setNeedsLayout];
}

- (void)setDarkTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.darkFontAttributes];
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(3.0, 3.0, size.width, size.height);
    [self setNeedsLayout];
}

- (CGSize)preferredFrameSize
{
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    size.width += 6.0;
    size.height += 6.0;
    return size;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    self.bottomEdgeLayer.frame = CGRectMake(0.0, 0.0, self.preferredFrameSize.width, 2.0);
    self.bounds = CGRectMake(0.0, 0.0, self.preferredFrameSize.width, self.preferredFrameSize.height);
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    if (self.isSelected) {
        return;
    }
    if (highlighted) {
        [self setDarkTitle:self.title];
    } else {
        [self setLightTitle:self.title];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    _highlighted = NO;
    
    if (selected) {
        [self setDarkTitle:self.title];
        self.bottomEdgeLayer.backgroundColor = self.darkColor.CGColor;
    } else {
        [self setLightTitle:self.title];
        self.bottomEdgeLayer.backgroundColor = self.backgroundColor;
    }
}

@end
