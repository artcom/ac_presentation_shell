//
//  OverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "OverlayLayer.h"

const float kLabelPaddingLeftRight = 10.0f;
const float kLabelPaddingBottom = 8.0f;

@interface OverlayLayer ()
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, strong) NSDictionary *titleAttribs;
@end

@implementation OverlayLayer


- (id)init {
	self = [super init];
	if (self != nil) {
		
		self.titleLayer = [CATextLayer layer];
		_titleLayer.wrapped = YES;
        _titleLayer.delegate = self;
		[self addSublayer:_titleLayer];
        
        NSFont *font = [NSFont fontWithName:@"ACSwiss-Bold" size:14.0f];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = 1.5f;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleAttribs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [NSColor whiteColor], NSParagraphStyleAttributeName : style };

        self.backgroundColor = [NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
		self.frame = CGRectMake(0, 0, 220, 100);
	}
	return self;
}

- (NSString *)text {
	return self.titleLayer.string;
}

- (CGSize)suggestedSizeForString:(NSAttributedString *)attrString constraints:(CGSize)constraints {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attrString length]), NULL, constraints, NULL);
    CFRelease(framesetter);
    return fitSize;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    
    // Size and position text label
    float textLabelWidth = CGRectGetWidth(self.bounds) - kLabelPaddingLeftRight * 2;
    CGSize fitSize = [self suggestedSizeForString:self.titleLayer.string constraints:NSMakeSize(textLabelWidth, CGFLOAT_MAX)];
    self.titleLayer.frame = CGRectMake(kLabelPaddingLeftRight, kLabelPaddingBottom, textLabelWidth, fitSize.height);
}

- (void)setText:(NSString *)newText {
	self.titleLayer.string = [[NSAttributedString alloc] initWithString:newText attributes:self.titleAttribs];;
}

- (void)setContentsScale:(CGFloat)contentsScale {
    [super setContentsScale:contentsScale];
    self.titleLayer.contentsScale = contentsScale;
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window {
    NSLog(@"TEST: textLayer of OverlayLayer is calling shouldInheritContentsScale with %f", newScale);
    return YES;
}


@end
