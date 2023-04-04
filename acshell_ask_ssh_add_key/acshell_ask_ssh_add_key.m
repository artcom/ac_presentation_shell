//
//  acshell_ask_ssh_add_key.m
//  ACShell
//
//  Created by David Siegel on 8/6/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

BOOL runAddKeyDialog(NSString * sshOutput) {
    NSDictionary *env = [[NSProcessInfo processInfo] environment];
    NSURL *iconUrl = [env objectForKey:@"ACSHELL_ICON_URL"];
    NSDictionary * dialogDescription = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"Add SSH Key", kCFUserNotificationAlertHeaderKey,
                                        sshOutput, kCFUserNotificationAlertMessageKey,
                                        iconUrl, kCFUserNotificationIconURLKey,
                                        @"Add Key", kCFUserNotificationDefaultButtonTitleKey,
                                        @"Cancel", kCFUserNotificationAlternateButtonTitleKey,
                                        nil];
    
    SInt32 error;
    CFUserNotificationRef dialog = CFUserNotificationCreate(kCFAllocatorDefault,
                                                            0,
                                                            kCFUserNotificationPlainAlertLevel,
                                                            &error,
                                                            (CFDictionaryRef)dialogDescription);
    if (error) {
        NSLog(@"failed to create user notification");
        CFRelease(dialog);
        return FALSE;
    }
    
    CFOptionFlags responseFlags;
    error = CFUserNotificationReceiveResponse(dialog, 0, &responseFlags);
    if (error) {
        NSLog(@"failed to receive response");
        CFRelease(dialog);
        return FALSE;
    }
    int button = responseFlags & 0x3;
    if (button == kCFUserNotificationDefaultResponse) {
        CFRelease(dialog);
        return TRUE;
    }
    CFRelease(dialog);
    return FALSE;
}

BOOL answerSSHQuestion() {
    NSArray * arguments = NSProcessInfo.processInfo.arguments;
    if ([arguments count] < 2) {
        NSLog(@"argument error: expected 2 but got %ld args", arguments.count);
        return FALSE;
    }
    
    NSString *yesNoSnippet = @"(yes/no";
    NSRange range = [arguments[1] rangeOfString:yesNoSnippet];
    if (range.location == NSNotFound) {
        NSLog(@"parser error: could not find expected input '%@'", yesNoSnippet);
        return FALSE;
    }
    
    BOOL addKey = runAddKeyDialog(arguments[1]);
    if (addKey) {
        printf("%s", "yes");
    } else {
        printf("%s", "no");
    }
    return addKey;
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        BOOL success = answerSSHQuestion();
        return success ? EXIT_SUCCESS : EXIT_FAILURE;
    }
}
