//
//  acshell_add_ssh_host_key.m
//  ACShell
//
//  Created by David Siegel on 8/6/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

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
    
    printf("%s", "yes");
    return TRUE;
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        BOOL success = answerSSHQuestion();
        return success ? EXIT_SUCCESS : EXIT_FAILURE;
    }
}
