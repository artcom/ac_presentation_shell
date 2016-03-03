//
//  PresentationHeaderView.m
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "PresentationHeaderView.h"

#define ITEM_SPACING 40.0;

@implementation PresentationHeaderView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers
{
    self.wantsLayer = YES;
    self.layer = [CALayer layer];
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    NSImage *logoImage = [NSImage imageNamed:@"presentation_logo"];
    self.logo = [CALayer layer];
    self.logo.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    self.logo.contents = logoImage;
    [self.layer addSublayer:self.logo];
    
    _categoryLayers = [NSMutableArray new];
}

- (void)updateLayout
{
    [self layoutResetLayer];
    [self layoutCategoryLayers];
    [self alignLayers];
    [self updateSelectedLayer];
}

- (void)layoutResetLayer
{
    [self.resetLayer removeFromSuperlayer];
    self.resetLayer = [HeaderLayer layer];
    self.resetLayer.title = @"All";
    [self.layer addSublayer:self.resetLayer];
}

- (void)layoutCategoryLayers
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.categoryLayers removeAllObjects];
    
    _categoryTitles = [self.dataSource titlesForCategoriesInPresentationHeaderView:self];
    for (NSString *title in self.categoryTitles) {
        HeaderLayer *layer = [HeaderLayer layer];
        layer.title = title;
        layer.selected = NO;
        [self.categoryLayers addObject:layer];
        [self.layer addSublayer:layer];
    }
}

- (void)alignLayers
{
    CGRect frame = CGRectMake(0.0, 0.0, self.resetLayer.preferredFrameSize.width, self.resetLayer.preferredFrameSize.height);
    frame.origin.x = self.layer.frame.size.width - frame.size.width;
    frame.origin.y = 0.0;
    frame.size.height = self.layer.frame.size.height;
    self.resetLayer.frame = frame;
    
    for (NSInteger i=self.categoryLayers.count-1; i >= 0; i--) {
        HeaderLayer *layer = self.categoryLayers[i];
        layer.bounds = CGRectMake(0.0, 0.0, layer.preferredFrameSize.width, layer.preferredFrameSize.height);
        
        CGFloat offset = 0.0;
        if (i == self.categoryLayers.count-1) {
            offset = self.resetLayer.frame.origin.x - ITEM_SPACING;
            offset -= layer.frame.size.width;
        } else {
            NSButton *previousLayer = self.categoryLayers[i+1];
            offset = previousLayer.frame.origin.x - ITEM_SPACING;
            offset -= layer.frame.size.width;
        }
        frame = layer.frame;
        frame.origin.x = offset;
        frame.origin.y = 0.0;
        frame.size.height = self.layer.frame.size.height;
        layer.frame = frame;
    }
}

- (void)updateSelectedLayer
{
    NSInteger index = [self.dataSource indexForSelectedCategoryInPresentationHeaderView:self];
    if (index < self.categoryLayers.count) {
        HeaderLayer *layer = self.categoryLayers[index];
        layer.selected = YES;
    } else {
        self.resetLayer.selected = YES;
    }
}

#pragma mark - Mouse handling

- (void)updateTrackingAreas
{
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options: (NSTrackingMouseEnteredAndExited |
                                                               NSTrackingMouseMoved |
                                                               NSTrackingActiveInKeyWindow)
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void) mouseEntered:(NSEvent *)theEvent
{
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
    if (layer == self.layer) {
        [self dehighlightAllLayers];
        return;
    }
    if ([layer isKindOfClass:CATextLayer.class]) {
        if (self.resetLayer.titleLayer == layer) {
            [self highlightResetLayer];
            return;
        }
        for (HeaderLayer *headerLayer in self.categoryLayers) {
            if (headerLayer.titleLayer == layer) {
                [self highlightCategoryLayer:headerLayer];
                break;
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
    if (layer == self.logo) {
        [self backLayerClicked];
    }
    if ([layer isKindOfClass:CATextLayer.class]) {
        if (self.resetLayer.titleLayer == layer) {
            [self selectResetLayer];
            return;
        }
        for (HeaderLayer *headerLayer in self.categoryLayers) {
            if (headerLayer.titleLayer == layer) {
                [self selectCategoryLayer:headerLayer];
                break;
            }
        }
    }
}

#pragma mark - Highlighting

- (void)highlightCategoryLayer:(HeaderLayer *)layer
{
    if (layer.isHighlighted) {
        return;
    }
    [self dehighlightAllLayers];
    layer.highlighted = YES;
}

- (void)highlightResetLayer
{
    if (self.resetLayer.isHighlighted) {
        return;
    }
    [self dehighlightAllLayers];
    self.resetLayer.highlighted = YES;
}

- (void)dehighlightAllLayers
{
    self.resetLayer.highlighted = NO;
    [self.categoryLayers makeObjectsPerformSelector:@selector(setHighlighted:) withObject:nil];
}

#pragma mark - Selecting

- (void)selectCategoryLayer:(HeaderLayer *)layer
{
    [self deselectAllLayers];
    layer.selected = YES;
    [self categoryLayerClicked:layer];
}

- (void)selectResetLayer
{
    [self deselectAllLayers];
    self.resetLayer.selected = YES;
    [self resetLayerClicked];
}

- (void)deselectAllLayers
{
    self.resetLayer.selected = NO;
    [self.categoryLayers makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
}

- (void)categoryLayerClicked:(HeaderLayer *)layer
{
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    [self.delegate presentationHeaderView:self didSelectCategoryAtIndex:index];
}

- (void)resetLayerClicked
{
    [self.delegate presentationHeaderViewDidClickResetButton:self];
}

- (void)backLayerClicked
{
    [self.delegate presentationHeaderViewDidClickBackButton:self];
}

@end
