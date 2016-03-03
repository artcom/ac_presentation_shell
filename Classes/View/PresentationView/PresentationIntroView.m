//
//  PresentationIntroView.m
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "PresentationIntroView.h"

@implementation PresentationIntroView

- (void)updateLayout
{
    
}

#pragma mark - Highlighting

- (void)highlightCategoryLayer:(IntroLayer *)layer
{
    [self dehighlightAllLayers];
    layer.highlighted = YES;
}

- (void)highlightResetLayer
{
    [self dehighlightAllLayers];
}

- (void)dehighlightAllLayers
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(setHighlighted:) withObject:nil];
}

#pragma mark - Selecting

- (void)selectCategoryLayer:(IntroLayer *)layer
{
    [self deselectAllLayers];
    layer.highlighted = YES;
    [self categoryLayerClicked:layer];
}

- (void)deselectAllLayers
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
}

- (void)categoryLayerClicked:(IntroLayer *)layer
{
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    [self.delegate presentationIntroView:self didSelectCategoryAtIndex:index];
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
        for (IntroLayer *introLayer in self.categoryLayers) {
            if (introLayer.titleLayer == layer) {
                [self highlightCategoryLayer:introLayer];
                break;
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
    if ([layer isKindOfClass:CATextLayer.class]) {
        for (IntroLayer *introLayer in self.categoryLayers) {
            if (introLayer.titleLayer == layer) {
                [self selectCategoryLayer:introLayer];
                break;
            }
        }
    }
}

@end
