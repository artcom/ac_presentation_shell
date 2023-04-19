//
//  NSAlert+Dialogs.m
//  ACShell
//
//  Created by Julian Krumow on 14.12.22.
//  Copyright © 2022 ART+COM AG. All rights reserved.
//

#import "NSAlert+Dialogs.h"

@implementation NSAlert (Dialogs)

+ (BOOL) runSuppressableBooleanDialogWithIdentifier: (NSString*) identifier
                                            message: (NSString*) message
                                               info: (NSString *) info
                                           okButton: (NSString*) ok
                                       cancelButton: (NSString*) cancel
                                  destructiveAction:(BOOL)hasDestructiveAction
{
    BOOL reallyDoIt = NO;
    NSString * userDefaultsKey = [NSString stringWithFormat: @"supress%@Dialog", identifier];
    BOOL suppressAlert = [NSUserDefaults.standardUserDefaults boolForKey: userDefaultsKey];
    if (suppressAlert ) {
        reallyDoIt = YES;
    } else {
        NSAlert *alert = NSAlert.new;
        alert.messageText = NSLocalizedString(message, nil);
        alert.informativeText = NSLocalizedString(info, nil);
        [alert addButtonWithTitle: NSLocalizedString(cancel, nil)];
        [alert addButtonWithTitle: NSLocalizedString(ok, nil)];
        if (hasDestructiveAction) {
            alert.buttons[1].hasDestructiveAction = hasDestructiveAction;
            alert.alertStyle = NSAlertStyleCritical;
        }
        [alert setShowsSuppressionButton: YES];
        
        if ([alert runModal] == NSAlertSecondButtonReturn) {
            reallyDoIt = YES;
        }
        [NSUserDefaults.standardUserDefaults setBool: alert.suppressionButton.state forKey: userDefaultsKey];
    }
    return reallyDoIt;
}

@end
