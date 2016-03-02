//
//  PresentationHeaderView.h
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationHeaderViewDataSource.h"
#import "PresentationHeaderViewDelegate.h"

@interface PresentationHeaderView : NSView

@property (nonatomic, weak) id <PresentationHeaderViewDataSource> dataSource;
@property (nonatomic, weak) id <PresentationHeaderViewDelegate> delegate;

@property (nonatomic, strong) CALayer *logo;
@property (nonatomic, strong) NSArray *categoryTitles;
@property (nonatomic, strong) NSMutableArray *categoryButtons;
@property (nonatomic, strong) NSButton *resetButton;

- (void)updateLayout;
@end
