//
//  PresentationIntroViewDataSource.h
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationIntroView;
@protocol PresentationIntroViewDataSource <NSObject>

- (NSArray *)titlesForCategoriesInPresentationIntroView:(PresentationIntroView *)presentationIntroView;
- (NSArray *)presentationIntroView:(PresentationIntroView *)presentationIntroView imagesForCategoryAtIndex:(NSInteger)index;
@end
