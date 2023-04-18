//
//  KeynoteLaunchDelegate.h
//  ACShell
//
//  Created by Julian Krumow on 18.04.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KeynoteHandler;
@protocol KeynoteLaunchDelegate <NSObject>
- (void)keynoteAppDidLaunch:(BOOL)success version:(NSString *)version;
- (void)keynoteDidRunInWindow:(KeynoteHandler *)keynote;
@end

NS_ASSUME_NONNULL_END
