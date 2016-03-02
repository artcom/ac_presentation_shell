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
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    NSImage *logoImage = [NSImage imageNamed:@"presentation_logo"];
    self.logo = [CALayer layer];
    self.logo.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    self.logo.contents = logoImage;
    
    self.layer = [CALayer layer];
    [self setWantsLayer:YES];
    [self.layer addSublayer:self.logo];
    
    _categoryButtons = [NSMutableArray new];
    _resetButton = [NSButton new];
    [self.resetButton setTitle:@"All"];
    [self.resetButton setTarget:self];
    [self.resetButton setAction:@selector(resetButtonClicked:)];
    [self addSubview:self.resetButton];
}

- (void)updateLayout
{
    [self configureButtons];
    [self layoutButtons];
}

- (void)configureButtons
{
    [_categoryButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_categoryButtons removeAllObjects];
    
    _categoryTitles = [self.dataSource titlesForCategoriesInPresentationHeaderView:self];
    for (NSString *title in self.categoryTitles) {
        NSButton *button = [NSButton new];
        [button setTitle:title];
        [button setTarget:self];
        [button setAction:@selector(categoryButtonClicked:)];
        [self.categoryButtons addObject:button];
        [self addSubview:button];
    }
}

- (void)layoutButtons
{
    [self.resetButton sizeToFit];
    NSRect frame = self.resetButton.frame;
    frame.origin.x = self.bounds.size.width - frame.size.width;
    self.resetButton.frame = frame;
    
    [self.categoryButtons makeObjectsPerformSelector:@selector(sizeToFit)];
    for (NSInteger i=self.categoryButtons.count-1; i >= 0; i--) {
        NSButton *button = self.categoryButtons[i];
        CGFloat offset = 0.0;
        if (i == self.categoryButtons.count-1) {
            offset = self.resetButton.frame.origin.x - BUTTON_SPACING;
            offset -= button.frame.size.width;
        } else {
            NSButton *previousButton = self.categoryButtons[i+1];
            offset = previousButton.frame.origin.x - BUTTON_SPACING;
            offset -= button.frame.size.width;
        }
        NSRect frame = button.frame;
        frame.origin.x = offset;
        button.frame = frame;
    }
}

- (void)categoryButtonClicked:(id)sender
{
    NSButton *button = (NSButton *)sender;
    NSInteger index = [self.categoryTitles indexOfObject:button.title];
    [self.delegate presentationHeaderView:self didSelectCategoryAtIndex:index];
}

- (void)resetButtonClicked:(id)sender
{
    [self.delegate presentationHeaderViewDidClickResetButton:self];
}

@end
