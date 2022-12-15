//
//  AssetImport.h
//  ACShell
//
//  Created by David Siegel on 8/8/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"

@class Presentation;

@interface AssetManager : NSObject {
    
    Presentation * presentation;
    
    NSMutableArray * assets;    
    int index;
    
    id<ProgressDelegateProtocol> delegate;
}

- (id) initWithPresentation: (Presentation*) presentation 
           progressDelegate: (id<ProgressDelegateProtocol>) delegate;

- (void) copyAsset: (NSString*) assetPath;
- (void) trashAsset: (NSString*) assetPath;
- (void) run;

@end
