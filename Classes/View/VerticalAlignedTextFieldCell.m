//
//  VerticalAlignedTextFieldCell.m
//  ACShell
//
//  Created by Julian Krumow on 08.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "VerticalAlignedTextFieldCell.h"

@implementation VerticalAlignedTextFieldCell

- (CGRect)adjustedFrame:(CGRect)rect
{
    CGRect titleRect = [super titleRectForBounds:rect];
    CGFloat minimumHeight = [self cellSizeForBounds:rect].height;
    titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2;
    titleRect.size.height = minimumHeight;
    
    return titleRect;
}

- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)delegate event:(NSEvent *)event
{
    [super editWithFrame:[self adjustedFrame:rect] inView:controlView editor:textObj delegate:delegate event:event];
}

- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)delegate start:(NSInteger)selStart length:(NSInteger)selLength
{
    [super selectWithFrame:[self adjustedFrame:rect] inView:controlView editor:textObj delegate:delegate start:selStart length:selLength];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:[self adjustedFrame:cellFrame] inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
