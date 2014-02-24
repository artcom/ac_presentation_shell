#import "HeightForWidthLayoutManager.h"

@implementation HeightForWidthLayoutManager

- (NSFont *)fontForTextLayer:(CATextLayer *)layer
{
    NSFont *font = nil;
    if ([(id)layer.font isKindOfClass:[NSFont class]]) {
        font = [NSFont fontWithName:[(NSFont *)layer.font fontName] size:layer.fontSize];
    }
    else if ([(id)layer.font isKindOfClass:[NSString class]]) {
        font = [NSFont fontWithName:(NSString *)layer.font size:layer.fontSize];
    }
    
    return font;
}

- (NSAttributedString *)attributedStringForTextLayer:(CATextLayer *)layer
{
	if ([layer.string isKindOfClass:[NSAttributedString class]]) {
        return layer.string;
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[self fontForTextLayer:layer]
                                                           forKey:NSFontAttributeName];
    
    return [[NSAttributedString alloc] initWithString:layer.string
                                            attributes:attributes];
}

- (CGSize)frameSizeForTextLayer:(CATextLayer *)layer {
    NSAttributedString *string = [self attributedStringForTextLayer:layer];
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CGFloat width = layer.bounds.size.width;
    
    CFIndex offset = 0, length;
    CGFloat y = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CFRelease(line);
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [string length]);
    
    CFRelease(typesetter);
    
    return CGSizeMake(width, ceil(y));
}

- (CGSize)preferredSizeOfLayer:(CALayer *)layer {
    if ([layer isKindOfClass:[CATextLayer class]] && ((CATextLayer *)layer).wrapped) {
        CGRect bounds = layer.bounds;
        bounds.size = [self frameSizeForTextLayer:(CATextLayer *)layer];
        layer.bounds = bounds;
    }
    
    return [super preferredSizeOfLayer:layer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    // Now adjust the height of any wrapped text layers, as their widths are known.
    for (CALayer *child in [layer sublayers]) {
        if ([child isKindOfClass:[CATextLayer class]]) {
            [self preferredSizeOfLayer:child];
        }
    }

    // Then let the regular constraints adjust any values that depend on heights.
    [super layoutSublayersOfLayer:layer];
}

@end
