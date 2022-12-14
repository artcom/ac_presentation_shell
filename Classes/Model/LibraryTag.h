//
//  LibraryTag.h
//  ACShell
//
//  Created by Julian Krumow on 08.12.22.
//  Copyright © 2022 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationLibrary;
@interface LibraryTag : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic) PresentationLibrary* context;

- (instancetype)initWithId:(NSString *)ID inContext:(PresentationLibrary *)context;
@end
