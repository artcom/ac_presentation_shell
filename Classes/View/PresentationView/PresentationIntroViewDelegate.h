//
//  PresentationIntroViewDelegate.h
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationIntroView;
@protocol PresentationIntroViewDelegate <NSObject>

- (void)presentationIntroView:(PresentationIntroView *)introView didSelectCategoryAtIndex:(NSInteger)index;
@end
