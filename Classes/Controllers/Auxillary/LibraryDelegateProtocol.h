//
//  LibraryDelegateProtocol.h
//  ACShell
//
//  Created by Julian Krumow on 04.04.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LibraryDelegateProtocol <NSObject>
- (void)operationDidFinish;
@end

NS_ASSUME_NONNULL_END
