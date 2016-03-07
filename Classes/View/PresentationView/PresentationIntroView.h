//
//  PresentationIntroView.h
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationIntroViewDataSource.h"
#import "PresentationIntroViewDelegate.h"
#import "IntroLayer.h"

@interface PresentationIntroView : NSView

@property (nonatomic, weak) IBOutlet id <PresentationIntroViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <PresentationIntroViewDelegate> delegate;

@property (nonatomic, strong) NSArray *categoryTitles;

- (void)updateLayout;
- (void)startSlideShow;
- (void)stopSlideShow;
@end
