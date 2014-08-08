//
//  PresentationViewDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol PresentationViewDelegate <NSObject>

@optional
- (void)presentationView:(PresentationView *)aView didClickItemAtIndex: (NSInteger)index; 
- (void)didUpdatePresentationView: (PresentationView *)aView;

@end
