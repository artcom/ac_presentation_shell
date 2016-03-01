//
//  Category.h
//  ACShell
//
//  Created by Julian Krumow on 01.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryCategory : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *directory;
@end
