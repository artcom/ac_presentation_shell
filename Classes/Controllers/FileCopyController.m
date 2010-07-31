//
//  FileCopyController.m
//  ACShell
//
//  Created by Robert Palmer on 26.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "FileCopyController.h"
#import "localized_text_keys.h"


@implementation FileCopyController
@synthesize delegate;
@synthesize isCopying;

- (id)initWithParentWindow: (NSWindow *)aWindow {
	self = [super init];
	if (self != nil) {
		window = [aWindow retain];
		isCopying = NO;
	}
	
	return self;
}


- (void)copy: (NSString *)source to: (NSString *)destination {
	
	NSString *sourceDir = [source stringByDeletingLastPathComponent];
	NSString *destinationDir = [destination stringByDeletingLastPathComponent];
	
	NSArray *files = [NSArray arrayWithObject:[source lastPathComponent]];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCopying:) 
												 name:NSWorkspaceDidPerformFileOperationNotification object:nil];
	
	progressSheet = [[NSAlert alloc] init];
	[progressSheet setMessageText:NSLocalizedString(ACSHELL_STR_UPDATE_PRESENTATION, nil)];
	[progressSheet setInformativeText:NSLocalizedString(ACSHELL_STR_TAKE_A_WHILE, nil)];
	
	NSProgressIndicator *spinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 300, 20)];
	[spinner startAnimation:self];
	[progressSheet setAccessoryView: spinner];
	
	[progressSheet beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	isCopying = YES;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSInteger tag;

		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation source:sourceDir destination:destinationDir files:files tag:&tag];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"tag: %d", tag);
			[self didFinishCopying:nil];
		});
	});
}


- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	NSLog(@"haha - can't cancel!!");
}

- (void)didFinishCopyingOperation: (NSNotification *)notification {
	NSLog(@"%s", _cmd);
}

- (void)didFinishCopying: (NSNotification *)notification {
	[NSApp endSheet:[progressSheet window]];
	
	[delegate fileCopyControllerDidFinish:self];
}

@end
