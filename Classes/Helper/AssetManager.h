//
//  AssetImport.h
//  ACShell
//
//  Created by David Siegel on 8/8/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"
#import "LibraryDelegateProtocol.h"

@class Presentation;

@interface AssetManager : NSObject
@property (nonatomic, strong) Presentation *presentation;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) int index;

@property (nonatomic, weak) id<ProgressDelegateProtocol> progressDelegate;
@property (nonatomic, weak) id<LibraryDelegateProtocol> libraryDelegate;

- (id) initWithPresentation: (Presentation*) presentation 
           progressDelegate: (id<ProgressDelegateProtocol>) delegate
                   delegate:(id<LibraryDelegateProtocol>)theDelegate;

- (void) copyAsset: (NSString*) assetPath;
- (void) trashAsset: (NSString*) assetPath;
- (void) run;
@end
