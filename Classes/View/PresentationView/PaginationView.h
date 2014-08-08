//
//  PaginationView.h
//  ACShell
//
//  Created by Robert Palmer on 02.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface PaginationView : NSView {
	NSInteger pages;
	NSInteger activePage;
	NSMutableArray *dots;
	
	NSImage *activeDot;
	NSImage *inactiveDot;
}

@property (assign, nonatomic) NSInteger pages;
@property (assign, nonatomic) NSInteger activePage;

@property (readonly) NSInteger dotsOnTop;
@property (readonly) NSInteger dotsOnBottom;

@property (nonatomic, strong) NSImage *activeDot;
@property (nonatomic, strong) NSImage *inactiveDot;

- (void)updateView;

@end
