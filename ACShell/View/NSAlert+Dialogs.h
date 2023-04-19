//
//  NSAlert+Dialogs.h
//  ACShell
//
//  Created by Julian Krumow on 14.12.22.
//  Copyright © 2022 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAlert (Dialogs)

+ (BOOL) runSuppressableBooleanDialogWithIdentifier: (NSString*) identifier
                                            message: (NSString*) message
                                               info: (NSString *)info
                                           okButton: (NSString*) ok
                                       cancelButton: (NSString*) cancel
                                  destructiveAction:(BOOL)hasDestructiveAction;
@end

NS_ASSUME_NONNULL_END
