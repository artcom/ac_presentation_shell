//
//  PresentationViewDataSource.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
@class PresentationView;

@protocol PresentationViewDataSource <NSObject>

- (NSArray *)titlesForCategoriesInPresentationView:(PresentationView *)aPresentationView;
- (NSInteger)numberOfItemsInPresentationView: (PresentationView *)aPresentationView;
- (CALayer *)presentationView: (PresentationView *)aPresentationView layerForItemAtIndex: (NSInteger)index;

@optional 
- (CALayer *)presentationView: (PresentationView *)aPresentationView hoverLayerForItemAtIndex: (NSInteger)index;
- (CGSize)sizeForItemInPresentationView: (PresentationView *)aPresentationView;

@end
