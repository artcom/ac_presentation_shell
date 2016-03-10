//
//  PresentationIntroView.m
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "PresentationIntroView.h"

#define LOGO_BOTTOM_PADDING 75.0

#define VIEW_PORT_WIDTH_LARGE  1400.0
#define VIEW_PORT_WIDTH_SMALL  1250.0
#define VIEW_PORT_HEIGHT_LARGE 1025.0

#define ITEM_WIDTH_LARGE 440.0
#define ITEM_WIDTH_MEDIUM 300.0
#define ITEM_WIDTH_SMALL 225.0
#define ITEM_HEIGHT_LARGE 130.0
#define ITEM_HEIGHT_SMALL 46.0

#define ITEM_SPACING 20.0

@interface PresentationIntroView ()
@property (nonatomic, strong) CALayer *logo;
@property (nonatomic, strong) CALayer *backgroundLayer;

@property (nonatomic, strong) NSMutableArray *categoryLayers;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSArray *backgroundImages;
@property (nonatomic, assign) NSInteger slideShowIndex;
@property (nonatomic, strong) NSTimer *slideShowTimer;
@property (nonatomic, strong) NSString *currentBackgroundImage;
@end

@implementation PresentationIntroView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidResize:)
                                                     name:NSViewFrameDidChangeNotification
                                                   object:self];
        [self setupLayers];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSViewFrameDidChangeNotification
                                                  object:self];
}

- (void)setupLayers
{
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor blackColor].CGColor;
    self.layer.contentsScale = self.window.backingScaleFactor;
    
    self.backgroundLayer = [CALayer layer];
    self.backgroundLayer.backgroundColor = [NSColor blackColor].CGColor;
    self.backgroundLayer.contentsScale = self.window.backingScaleFactor;
    [self.layer addSublayer:self.backgroundLayer];
    
    self.logo = [CALayer layer];
    self.logo.contentsScale = self.window.backingScaleFactor;
    [self.layer addSublayer:self.logo];
    
    _categoryLayers = [NSMutableArray new];
}

- (void)updateLayout
{
    [self layoutCategoryLayers];
    [self alignLayers];
    [self setupSlideShow];
}

- (void)layoutCategoryLayers
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.categoryLayers removeAllObjects];
    
    _categoryTitles = [self.dataSource titlesForCategoriesInPresentationIntroView:self];
    for (NSString *title in self.categoryTitles) {
        IntroLayer *layer = [IntroLayer layer];
        layer.contentsScale = self.window.backingScaleFactor;
        layer.title = title;
        layer.highlighted = NO;
        [self.categoryLayers addObject:layer];
        [self.layer addSublayer:layer];
    }
}

- (void)alignLayers
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundLayer.frame = self.bounds;
    [CATransaction commit];
    
    CGSize itemSize = [self preferredItemSize];
    CGFloat itemSetWidth = (self.categoryLayers.count * itemSize.width) + (ITEM_SPACING * (self.categoryLayers.count - 1));
    CGFloat x = (self.bounds.size.width - itemSetWidth) / 2.0;
    CGFloat y = (self.bounds.size.height - itemSize.height) / 2.0;
    
    for (IntroLayer *layer in self.categoryLayers) {
        layer.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
        x += ITEM_SPACING + itemSize.width;
    }
    
    NSString *logoName = [self logoNameForItemSize:itemSize];
    NSImage *logoImage = [NSImage imageNamed:logoName];
    self.logo.contents = logoImage;
    x = (self.bounds.size.width - logoImage.size.width) / 2.0;
    y += itemSize.height + LOGO_BOTTOM_PADDING;
    self.logo.frame = CGRectMake(x, y, logoImage.size.width, logoImage.size.height);
}

- (NSString *)logoNameForItemSize:(CGSize)size
{
    NSString *name = @"ac_logo_white_small";
    if (size.width == ITEM_WIDTH_LARGE) {
        name = @"ac_logo_white_large";
    } else if (size.width == ITEM_WIDTH_MEDIUM) {
        name = @"ac_logo_white_medium";
    }
    return name;
}

- (CGSize)preferredItemSize
{
    CGFloat width = ITEM_WIDTH_SMALL;
    if (self.bounds.size.width > VIEW_PORT_WIDTH_LARGE) {
        width = ITEM_WIDTH_LARGE;
    } else if (self.bounds.size.width > VIEW_PORT_WIDTH_SMALL) {
        width = ITEM_WIDTH_MEDIUM;
    }
    CGFloat height = ITEM_HEIGHT_SMALL;
    if (self.bounds.size.height > VIEW_PORT_HEIGHT_LARGE) {
        height = ITEM_HEIGHT_LARGE;
    }
    return CGSizeMake(width, height);
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

- (void)categoryLayerClicked:(IntroLayer *)layer
{
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    [self.delegate presentationIntroView:self didSelectCategoryAtIndex:index];
}

#pragma mark - Slide show

- (void)setupSlideShow
{
    [self stopTimer];
    [self pickBackgroundImages];
    
    self.slideShowIndex = 0;
    self.currentBackgroundImage = self.backgroundImages[self.slideShowIndex];
    [self highlightCategoryLayer:self.categoryLayers[self.slideShowIndex]];
    [self updateBackgroundImageAtCurrentIndexAnimated:NO];
}

- (void)startSlideShow
{
    [self startFastTimer];
}

- (void)stopSlideShow
{
    [self stopTimer];
}

- (void)pickBackgroundImages
{
    NSMutableArray *backgroundImages = [NSMutableArray new];
    for (NSInteger i=0; i < self.categoryTitles.count; i++) {
        NSArray *images = [self.dataSource presentationIntroView:self imagesForCategoryAtIndex:i];
        NSInteger index = random() % images.count;
        [backgroundImages addObject:images[index]];
    }
    _backgroundImages = backgroundImages;
}

- (void)showNextSlide:(id)userInfo
{
    [self stopTimer];
    self.slideShowIndex++;
    if (self.slideShowIndex >= self.categoryTitles.count) {
        self.slideShowIndex = 0;
    }
    [self highlightCategoryLayer:self.categoryLayers[self.slideShowIndex]];
    [self updateBackgroundImageAtCurrentIndexAnimated:YES];
    [self startTimer];
}

- (void)showSlideForLayer:(IntroLayer *)layer
{
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    if (self.slideShowIndex == index) {
        return;
    }
    
    self.slideShowIndex = index;
    [self stopTimer];
    [self highlightCategoryLayer:layer];
    [self updateBackgroundImageAtCurrentIndexAnimated:YES];
    [self startTimer];
}

- (void)updateBackgroundImageAtCurrentIndexAnimated:(BOOL)animated
{
    _currentBackgroundImage = self.backgroundImages[self.slideShowIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.currentBackgroundImage];
    
    if (animated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        self.backgroundLayer.contents = image;
        [CATransaction commit];
    } else {
        self.backgroundLayer.contents = image;
    }
}

- (void)startTimer
{
    self.slideShowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                           target:self
                                                         selector:@selector(showNextSlide:)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)startFastTimer
{
    self.slideShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(showNextSlide:)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)stopTimer
{
    [self.slideShowTimer invalidate];
    self.slideShowTimer = nil;
}

#pragma mark - View handling

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
    [super resizeWithOldSuperviewSize:oldBoundsSize];
    [self viewDidResize:nil];
}

- (void)viewDidResize: (NSNotification *)aNotification
{
    [self updateLayout];
}

- (void)viewDidChangeBackingProperties
{
    CGFloat backingScaleFactor = self.window.backingScaleFactor;
    self.layer.contentsScale = backingScaleFactor;
    self.logo.contentsScale = backingScaleFactor;
    self.backgroundLayer.contentsScale = backingScaleFactor;
    for (CALayer *layer in self.categoryLayers) {
        layer.contentsScale = backingScaleFactor;
    }
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window {
    return YES;
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
    }
    if ([self.categoryLayers containsObject:layer]) {
        [self showSlideForLayer:(IntroLayer *)layer];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
    
    if ([self.categoryLayers containsObject:layer]) {
        [self categoryLayerClicked:(IntroLayer *)layer];
        
    } else if ([layer isKindOfClass:CATextLayer.class]) {
        for (IntroLayer *introLayer in self.categoryLayers) {
            if (introLayer.titleLayer == layer) {
                [self categoryLayerClicked:introLayer];
                break;
            }
        }
    }
}

@end
