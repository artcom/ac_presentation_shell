//
//  PresentationView.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PresentationHeaderView.h"
#import "PresentationViewDataSource.h"
#import "PresentationViewDelegate.h"
@class GridLayout;
@class PaginationView;

@interface PresentationView : NSView <PresentationHeaderViewDataSource, PresentationHeaderViewDelegate, CALayerDelegate> {
    
    NSInteger hoveredItem;
    PaginationView *paginationView;
    NSButton *pageButtons;
}

@property (weak, nonatomic) IBOutlet id <PresentationViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id <PresentationViewDelegate> delegate;
@property (assign, nonatomic) NSInteger page;
@property (assign, readonly) NSInteger pages;
@property (strong, nonatomic) CALayer *hoverLayer;
@property (strong) GridLayout *gridLayout;
@property (nonatomic, strong) PresentationHeaderView *headerView;

- (void)arrangeSublayer;
- (BOOL)hasNextPage;
- (BOOL)hasPreviousPage;

- (NSInteger)lastItemOnPage;
- (NSInteger)firstItemOnPage;
- (NSInteger)indexOfItemOnPage: (NSInteger)index;

- (void)addOverlay: (CALayer *)newOverlay forItem: (NSInteger)index;

@end
