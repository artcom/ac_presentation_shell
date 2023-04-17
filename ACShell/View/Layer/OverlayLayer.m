//
//  OverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "OverlayLayer.h"
#import "CATextLayer+Calculations.h"

const float kLabelPaddingLeftRight = 10.0f;
const float kLabelPaddingBottom = 8.0f;

@interface OverlayLayer ()
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) NSDictionary *titleAttribs;
@property (nonatomic, strong) NSFont *titleFont;
@end

@implementation OverlayLayer


- (id)init {
    self = [super init];
    if (self != nil) {
        
        self.titleLayer = CATextLayer.layer;
        _titleLayer.wrapped = YES;
        _titleLayer.delegate = self;
        [self addSublayer:_titleLayer];
        
        self.titleFont = [NSFont fontWithName:@"ACSwiss-Bold" size:14.0f];
        self.titleAttribs = @{ NSFontAttributeName : _titleFont, NSForegroundColorAttributeName : [NSColor whiteColor] };
        
        self.backgroundColor = [NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.75f].CGColor;
        self.frame = CGRectMake(0, 0, 220, 100);
    }
    return self;
}

- (NSString *)text {
    return self.titleLayer.string;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    
    // Size and position text label
    float textLabelWidth = CGRectGetWidth(self.bounds) - kLabelPaddingLeftRight * 2;
    CGSize fitSize = [CATextLayer suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(textLabelWidth, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(kLabelPaddingLeftRight, kLabelPaddingBottom, textLabelWidth, fitSize.height - self.titleFont.descender);
}

- (void)setText:(NSString *)newText {
    self.titleLayer.string = [[NSAttributedString alloc] initWithString:newText attributes:self.titleAttribs];;
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
