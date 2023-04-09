//
//  NSString+AppendSlash.h
//  ACShell
//
//  Created by Julian Krumow on 09.04.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AppendSlash)
- (NSString*) stringByAppendingSlash;
@end

NS_ASSUME_NONNULL_END
