//
//  PresentationHeaderView.m
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "PresentationHeaderView.h"

#define BUTTON_SPACING 40.0;

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
    NSImage *logoImage = [NSImage imageNamed:@"presentation_logo"];
    self.logo = [CALayer layer];
    self.logo.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    self.logo.contents = logoImage;
    
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    [self.layer addSublayer:self.logo];
    
    self.resetLayer = [HeaderLayer layer];
    self.resetLayer.title = @"All";
    
    _categoryLayers = [NSMutableArray new];
}

- (void)updateLayout
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.categoryLayers removeAllObjects];
    
    _categoryTitles = [self.dataSource titlesForCategoriesInPresentationHeaderView:self];
    for (NSString *title in self.categoryTitles) {
        
        HeaderLayer *layer = [HeaderLayer layer];
        [self.categoryLayers addObject:layer];
        [self.layer addSublayer:layer];
        
        layer.title = title;
        layer.highlighted = NO;
    }
    
    [self layoutSublayersOfLayer:self.layer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (layer == self.layer) {
        NSRect frame = self.resetLayer.frame;
        frame.origin.x = self.layer.bounds.size.width - frame.size.width;
        self.resetLayer.frame = frame;
        
        for (NSInteger i=self.categoryLayers.count-1; i >= 0; i--) {
            HeaderLayer *layer = self.categoryLayers[i];
            CGFloat offset = 0.0;
            if (i == self.categoryLayers.count-1) {
                offset = self.resetLayer.frame.origin.x - BUTTON_SPACING;
                offset -= layer.frame.size.width;
            } else {
                NSButton *previousLayer = self.categoryLayers[i+1];
                offset = previousLayer.frame.origin.x - BUTTON_SPACING;
                offset -= layer.frame.size.width;
            }
            CGRect frame = layer.frame;
            frame.origin.x = offset;
            layer.frame = frame;
        }
    }
}

- (void)categoryLayerClicked:(HeaderLayer *)layer
{
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    [self.delegate presentationHeaderView:self didSelectCategoryAtIndex:index];
}

- (void)resetLayerClicked:(HeaderLayer *)layer
{
    [self.delegate presentationHeaderViewDidClickResetButton:self];
}

@end
