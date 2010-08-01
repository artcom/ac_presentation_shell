//
//  FirstRunAssistantController.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "SetupAssistantController.h"
#import "localized_text_keys.h"

@interface SshIdentityFile : NSObject {
    NSString * path;
}

@property (retain) NSString * path;
@property (readonly) NSString * filename;


- (id) initWithPath: (NSString*) path;

@end

@implementation SshIdentityFile
@synthesize path;
- (id) initWithPath: (NSString*) aPath {
    self = [super init];
    if (self != nil) {
        self.path = aPath;
    }
    return self;
}
- (NSString*) filename {
    return [path lastPathComponent];
}

@end

NSString * sshDirString();
NSString * sshPrivateKeyFilename();
NSString * sshPublicKeyFilename();

@interface SetupAssistantController ()

- (void) updateButtons: (NSTabViewItem*) item;
- (void) setupSshIdentityPage;
- (void) updatePublicKeyList;

@end

enum PageTags {
    SETUP_PAGE_WELCOME,
    SETUP_PAGE_SSH_IDENTITY
};

@implementation SetupAssistantController
@synthesize pages;
@synthesize nextButton;
@synthesize backButton;
@synthesize publicKeyArrayController;
@synthesize publicKeyTable;
@synthesize generateSshKeysButton;
@synthesize sshKeygenSpinner;

- (id) init {
    self = [super initWithWindowNibName: @"SetupAssistant"];
    if (self) {
        publicKeys = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [publicKeys release];
    
    [super dealloc];
}

- (void) awakeFromNib {
    [pages selectFirstTabViewItem: nil];
    numPages = [pages numberOfTabViewItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publicKeySelectionDidChange:)
                                                 name:NSTableViewSelectionDidChangeNotification object: publicKeyTable];
    
}

- (IBAction) userDidClickNext: (id) sender {
    [pages selectNextTabViewItem: sender];
}

- (IBAction) userDidClickBack: (id) sender {
    // TODO: find a better way to check for the first page
    if ([backButton.title isEqual: NSLocalizedString(ACSHELL_STR_QUIT, nil)]) {
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    } else {
        [pages selectPreviousTabViewItem: sender];
    }
}


- (void) updateButtons: (NSTabViewItem*) item {
    NSInteger index = [pages indexOfTabViewItem: item];
    if (index == numPages - 1) {
        [nextButton setTitle: NSLocalizedString(ACSHELL_STR_FINISH, nil)];
        [backButton setTitle: NSLocalizedString(ACSHELL_STR_BACK, nil)];
    } else if (index == 0) {
        [nextButton setTitle: NSLocalizedString(ACSHELL_STR_CONTINUE, nil)];
        [backButton setTitle: NSLocalizedString(ACSHELL_STR_QUIT, nil)];
    } else {
        [nextButton setTitle: NSLocalizedString(ACSHELL_STR_NEXT, nil)];
        [backButton setTitle: NSLocalizedString(ACSHELL_STR_BACK, nil)];
    }
}

- (void) tabView: (NSTabView*) tabView didSelectTabViewItem: (NSTabViewItem*) item {
    [self updateButtons: item];
    switch ([tabView indexOfTabViewItem: item]) {
        case SETUP_PAGE_WELCOME:
            break;
        case SETUP_PAGE_SSH_IDENTITY:
            [self setupSshIdentityPage];
            break;
        default:
            break;
    }
}

- (void) setupSshIdentityPage {
    [self updatePublicKeyList];
    [nextButton setEnabled: [publicKeyArrayController selectionIndex] != NSNotFound];
    BOOL idFileExists = [[NSFileManager defaultManager] fileExistsAtPath: sshPublicKeyFilename() isDirectory: nil];
    [generateSshKeysButton setEnabled: ! idFileExists];
}

- (void) updatePublicKeyList {
    NSArray * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: sshDirString() error: nil];
    NSArray * publicKeyPaths = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.pub'"]];
    [publicKeys removeAllObjects];
    for (NSString * path in publicKeyPaths) {
        [publicKeys addObject: [[[SshIdentityFile alloc] initWithPath: path] autorelease]];
    }
    [publicKeyArrayController setContent: publicKeys];
}

- (void) publicKeySelectionDidChange: (NSNotification *) notification {
    NSLog(@"=====");
    [nextButton setEnabled: [publicKeyArrayController selectionIndex] != NSNotFound];
}

- (IBAction) generateSshKeys: (id) sender {
    [sshKeygenSpinner setHidden: NO];
    [sshKeygenSpinner startAnimation: nil];
    NSString * sshDir = sshDirString();
    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath: sshDir isDirectory: nil];
    if ( ! dirExists ) {
        NSError * error;
        if ( ! [[NSFileManager defaultManager] createDirectoryAtPath: sshDir withIntermediateDirectories: YES attributes:nil error: &error]) {
            // TODO: better error handling
            NSLog(@"Failed to create .ssh directory");
            return;
        }
    }
    NSArray * args = [NSArray arrayWithObjects: @"-b", @"4096", @"-N", @"", @"-f", sshPrivateKeyFilename(), nil];
    NSTask * sshKeygenTask = [[NSTask alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSshKeygen:)
												 name:NSTaskDidTerminateNotification object:sshKeygenTask];

    [sshKeygenTask setLaunchPath: @"/usr/bin/ssh-keygen"];
    [sshKeygenTask setArguments: args];
    [sshKeygenTask launch];
}

- (void) didFinishSshKeygen: (NSNotification*) notification {
    NSLog(@"==== keygen done");
    [self updatePublicKeyList];
    [sshKeygenSpinner setHidden: YES];
    [sshKeygenSpinner stopAnimation: nil];
}

NSString * sshDirString() {
    return [[NSString stringWithString: @"~/.ssh/"] stringByExpandingTildeInPath];
}

NSString * sshPrivateKeyFilename() {
    return [sshDirString() stringByAppendingPathComponent: @"id_rsa"];
}

NSString * sshPublicKeyFilename() {
    return [sshPrivateKeyFilename() stringByAppendingPathExtension: @"pub"];
}

@end
