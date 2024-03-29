//
//  IntroLayer.m
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "IntroLayer.h"
#import "CATextLayer+Calculations.h"

@interface IntroLayer ()
@property (nonatomic, strong) NSColor *defaultBackgroundColor;
@property (nonatomic, strong) NSColor *highlightedBackgroundColor;
@property (nonatomic, strong) NSColor *defaultFontColor;
@property (nonatomic, strong) NSColor *highlightedFontColor;
@property (nonatomic, strong) NSDictionary *defaultFontAttributes;
@property (nonatomic, strong) NSDictionary *highlightedFontAttributes;
@end

@implementation IntroLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _defaultBackgroundColor = [NSColor clearColor];
        _highlightedBackgroundColor = [NSColor whiteColor];
        
        _defaultFontColor = [NSColor whiteColor];
        _highlightedFontColor = [NSColor colorWithCalibratedRed:0.1372 green:0.1372 blue:0.1372 alpha:1.0];
        
        NSFont *defaultFont = [NSFont fontWithName:@"LMSansQuot8-Regular" size:22.0];
        _defaultFontAttributes = @{NSFontAttributeName:defaultFont,
                                   NSForegroundColorAttributeName:self.defaultFontColor,
                                   NSKernAttributeName:@2.0};
        
        NSFont *highlightedFont = [NSFont fontWithName:@"LMSansQuot8-Regular" size:22.0];
        _highlightedFontAttributes = @{NSFontAttributeName:highlightedFont,
                                       NSForegroundColorAttributeName:self.highlightedFontColor,
                                       NSKernAttributeName:@2.0};
        
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers
{
    self.backgroundColor = self.defaultBackgroundColor.CGColor;
    self.borderColor = self.highlightedBackgroundColor.CGColor;
    self.borderWidth = 3.0;
    
    self.titleLayer = CATextLayer.layer;
    [self addSublayer:self.titleLayer];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setDefaultTitle:title];
}

- (void)setDefaultTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.defaultFontAttributes];
    [self setNeedsLayout];
}

- (void)setHighlightedTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.highlightedFontAttributes];
    [self setNeedsLayout];
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    CGSize titleSize = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    CGFloat x = (self.bounds.size.width - titleSize.width) / 2.0;
    CGFloat y = (self.bounds.size.height - titleSize.height) / 2.0;
    self.titleLayer.frame = CGRectMake(x, y, titleSize.width, titleSize.height);
    self.titleLayer.transform = CATransform3DMakeScale(1.0f, 1.05f, 1.0f);
}

- (void)setDefaultBackground
{
    self.backgroundColor = self.defaultBackgroundColor.CGColor;
}

- (void)setHighlightedBackground
{
    self.backgroundColor = self.highlightedBackgroundColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    if (highlighted) {
        [self setHighlightedTitle:self.title];
        [self setHighlightedBackground];
    } else {
        [self setDefaultTitle:self.title];
        [self setDefaultBackground];
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
