//
//  PresentationHeaderViewDelegate.h
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationHeaderView;
@protocol PresentationHeaderViewDelegate <NSObject>

- (void)presentationHeaderView:(PresentationHeaderView *)headerView didSelectCategoryAtIndex:(NSInteger)index;
- (void)presentationHeaderViewDidClickResetButton:(PresentationHeaderView *)headerView;
@end
