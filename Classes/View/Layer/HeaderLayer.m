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
@property (nonatomic, strong) NSColor *defaultFontColor;
@property (nonatomic, strong) NSColor *highlightedFontColor;
@property (nonatomic, strong) NSDictionary *defaultFontAttributes;
@property (nonatomic, strong) NSDictionary *highlightedFontAttributes;
@end

@implementation HeaderLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _defaultFontColor = [NSColor colorWithCalibratedRed:0.5725 green:0.5725 blue:0.5725 alpha:1.0];
        _highlightedFontColor = [NSColor colorWithCalibratedRed:0.1372 green:0.1372 blue:0.1372 alpha:1.0];
        
        NSFont *font = [NSFont fontWithName:@"LMSansQuot8-Regular" size:13.0f];
        _defaultFontAttributes = @{NSFontAttributeName:font,
                                   NSForegroundColorAttributeName:self.defaultFontColor};
        
        _highlightedFontAttributes = @{NSFontAttributeName:font,
                                       NSForegroundColorAttributeName:self.highlightedFontColor};
        
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

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setDefaultTitle:title];
}

- (void)setDefaultTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.defaultFontAttributes];
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(3.0, 5.0, size.width, size.height);
    [self setNeedsLayout];
}

- (void)setHighlightedTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.highlightedFontAttributes];
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(3.0, 5.0, size.width, size.height);
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
    self.bottomEdgeLayer.frame = CGRectMake(3.0, 0.0, self.titleLayer.bounds.size.width, 2.0);
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    if (self.isSelected) {
        return;
    }
    if (highlighted) {
        [self setHighlightedTitle:self.title];
    } else {
        [self setDefaultTitle:self.title];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    _highlighted = NO;
    
    if (selected) {
        [self setHighlightedTitle:self.title];
        self.bottomEdgeLayer.backgroundColor = self.highlightedFontColor.CGColor;
    } else {
        [self setDefaultTitle:self.title];
        self.bottomEdgeLayer.backgroundColor = self.backgroundColor;
    }
}

- (void)setContentsScale:(CGFloat)contentsScale
{
    [super setContentsScale:contentsScale];
    self.titleLayer.contentsScale = contentsScale;
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window
{
    return YES;
}

@end
