//
//  PresentationHeaderViewDataSource.h
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationHeaderView;
@protocol PresentationHeaderViewDataSource <NSObject>

- (NSArray *)titlesForCategoriesInHeaderView:(PresentationHeaderView *)headerView;
- (NSInteger)indexForSelectedCategoryInHeaderView:(PresentationHeaderView *)headerView;
@end
