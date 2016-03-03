//
//  PresentationIntroView.m
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "PresentationIntroView.h"

#define LOGO_BOTTOM_PADDING 75.0
#define ITEM_SPACING 20.0

#define ITEM_WIDTH_LARGE 440.0
#define ITEM_WIDTH_MEDIUM 300.0
#define ITEM_WIDTH_SMALL 225.0

#define ITEM_HEIGHT_LARGE 130.0
#define ITEM_HEIGHT_MEDIUM 130.0
#define ITEM_HEIGHT_SMALL 46.0

@interface PresentationIntroView ()
@property (nonatomic, strong) NSMutableArray *categoryLayers;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSArray *backgroundImages;
@property (nonatomic, assign) NSInteger slideShowIndex;
@property (nonatomic, strong) NSTimer *slideShowTimer;
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
    self.wantsLayer = YES;
    self.layer = [CALayer layer];
    self.layer.backgroundColor = [NSColor blackColor].CGColor;
    
    NSImage *logoImage = [NSImage imageNamed:@"presentation_logo"];
    self.logo = [CALayer layer];
    self.logo.frame = CGRectMake(100.0, 100.0, logoImage.size.width, logoImage.size.height);
    self.logo.contents = logoImage;
    [self.layer addSublayer:self.logo];
    
    _categoryLayers = [NSMutableArray new];
}

- (void)updateLayout
{
    [self layoutCategoryLayers];
    [self alignLayers];
    
    [self startSlideShow];
}

- (void)layoutCategoryLayers
{
    [self.categoryLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.categoryLayers removeAllObjects];
    
    _categoryTitles = [self.dataSource titlesForCategoriesInPresentationIntroView:self];
    for (NSString *title in self.categoryTitles) {
        IntroLayer *layer = [IntroLayer layer];
        layer.title = title;
        layer.highlighted = NO;
        [self.categoryLayers addObject:layer];
        [self.layer addSublayer:layer];
    }
}

- (void)alignLayers
{
    CGFloat itemSetWidth = (self.categoryLayers.count * ITEM_WIDTH_LARGE) + (ITEM_SPACING * self.categoryLayers.count - 1);
    CGFloat x = (self.bounds.size.width - itemSetWidth) / 2.0;
    CGFloat y = (self.bounds.size.height - ITEM_HEIGHT_LARGE) / 2.0;
    
    for (IntroLayer *layer in self.categoryLayers) {
        layer.frame = CGRectMake(x, y, ITEM_WIDTH_LARGE, ITEM_HEIGHT_LARGE);
        x += ITEM_WIDTH_LARGE + ITEM_SPACING;
    }
    
    x = (self.bounds.size.width - self.logo.bounds.size.width) / 2.0;
    y += ITEM_HEIGHT_LARGE + LOGO_BOTTOM_PADDING;
    self.logo.frame = CGRectMake(x, y, self.logo.bounds.size.width, self.logo.bounds.size.height);
}

#pragma mark - Highlighting

- (void)highlightCategoryLayer:(IntroLayer *)layer
{
    if (layer.isHighlighted) {
        return;
    }
    
    [self dehighlightAllLayers];
    layer.highlighted = YES;
    
    NSInteger index = [self.categoryLayers indexOfObject:layer];
    self.slideShowIndex = index;
    
    [self updateBackgroundImageAtCurrentIndex];
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

- (void)startSlideShow
{
    [self.slideShowTimer invalidate];
    
    NSMutableArray *backgroundImages = [NSMutableArray new];
    
    for (NSInteger i=0; i < self.categoryTitles.count; i++) {
        NSArray *images = [self.dataSource presentationIntroView:self imagesForCategoryAtIndex:i];
        [backgroundImages addObject:images.lastObject];
    }
    _backgroundImages = backgroundImages;
    self.slideShowIndex = 0;
    [self updateBackgroundImageAtCurrentIndex];
    
    self.slideShowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                           target:self
                                                         selector:@selector(showNextSlide:)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)showNextSlide:(id)userInfo
{
    self.slideShowIndex++;
    if (self.slideShowIndex >= self.categoryTitles.count) {
        self.slideShowIndex = 0;
    }
    [self updateBackgroundImageAtCurrentIndex];
}

- (void)updateBackgroundImageAtCurrentIndex
{
    NSString *imagePath = self.backgroundImages[self.slideShowIndex];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    self.layer.contents = image;
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
        [self highlightCategoryLayer:(IntroLayer *)layer];
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
