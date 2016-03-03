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
        
        NSFont *font = [NSFont fontWithName:@"ACSwiss" size:13.0f];
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
    self.backgroundColor = NSColor.clearColor.CGColor;
    self.borderColor = self.defaultBackgroundColor.CGColor;
    self.borderWidth = 3.0;
    
    NSImage *logoImage = [NSImage imageNamed:@"presentation_logo"];
    self.logo = [CALayer layer];
    self.logo.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    self.logo.contents = logoImage;
    [self addSublayer:self.logo];
    
    self.titleLayer = [CATextLayer layer];
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
    CGSize size = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(0, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(3.0, 3.0, size.width, size.height);
    [self setNeedsLayout];
}

- (void)setHighlightedTitle:(NSString *)title
{
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:self.highlightedFontAttributes];
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

@end
