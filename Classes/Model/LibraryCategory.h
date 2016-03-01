//
//  Category.h
//  ACShell
//
//  Created by Julian Krumow on 01.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PresentationLibrary;
@interface LibraryCategory : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic) PresentationLibrary* context;

- (NSString *)title;
- (NSString *)directory;

- (instancetype)initWithId:(NSString *)ID inContext:(PresentationLibrary*)context;
@end
