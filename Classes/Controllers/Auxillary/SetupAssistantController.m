//
//  SetupAssistantController.m
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "SetupAssistantController.h"
#import "LibraryServer.h"
#import "SshIdentity.h"
#import "PublicKeyDraglet.h"
#import "localized_text_keys.h"
#import "default_keys.h"

#define ACSHELL_BONJOUR_TYPE @"_acshell._tcp"

#define ACSHELL_RSYNC_READ_USER_DEFAULT @"pr-reader"
#define ACSHELL_RSYNC_WRITE_USER_DEFAULT @"pr-editor"

//=== Prototypes ===============================================================

NSString * sshDirString();
NSString * sshPrivateKeyFilename();
NSString * sshPublicKeyFilename();

//=== SetupAssistantController =================================================

@interface SetupAssistantController ()

- (void) updateButtons: (NSTabViewItem*) item;
- (void) setupSshIdentityPage;
- (void) updatePublicKeyList;
- (void) setupSubscritptionPage;
- (void) setupSendMailPage;
- (void) writeUserDefaults;

-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode;

@end

enum PageTags {
    SETUP_PAGE_WELCOME,
    SETUP_PAGE_SSH_IDENTITY,
    SETUP_PAGE_SUBSCRIBE_LIBRARY,
    SETUP_PAGE_SEND_MAIL
};

@implementation SetupAssistantController
@synthesize pages;
@synthesize nextButton;
@synthesize backButton;
@synthesize publicKeyArrayController;
@synthesize publicKeyTable;
@synthesize generateSshKeysButton;
@synthesize sshKeygenSpinner;
@synthesize bonjourServerList;
@synthesize rsyncSourceEntry;
@synthesize bonjourLibrariesArrayController;
@synthesize publicKeys;
@synthesize bonjourLibraries;
@synthesize discoveryModeButtons;
@synthesize libraryNameLabel;
@synthesize administratorAddressLabel;
@synthesize publicKeyDraglet;
@synthesize emailSendToggle;
@synthesize sshKeygenTask;

- (id) initWithDelegate: (id<SetupAssistantDelegate>) theDelegate {
    self = [super initWithWindowNibName: @"SetupAssistant"];
    if (self) {
        publicKeys = [[NSMutableArray alloc] init];
        bonjourBrowserRunning = NO;
        bonjourBrowser = [[NSNetServiceBrowser alloc] init];
        [bonjourBrowser setDelegate: self];
        bonjourLibraries = [[NSMutableArray alloc] init];
        delegate = theDelegate;
    }
    return self;
}


- (void) awakeFromNib {
    [pages selectFirstTabViewItem: nil];
    numPages = [pages numberOfTabViewItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publicKeySelectionDidChange:)
                                                 name:NSTableViewSelectionDidChangeNotification object: publicKeyTable];
    
    [bonjourServerList addObserver: self forKeyPath: @"selectionIndexes" options: NSKeyValueObservingOptionNew context:nil];
}

- (IBAction) userDidClickNext: (id) sender {
    // TODO: find a better way to check for the last page
    if ([nextButton.title isEqual: NSLocalizedString(ACSHELL_STR_FINISH, nil)]) {
        [self writeUserDefaults];
        NSAlert * alert = [NSAlert new];
        alert.messageText = NSLocalizedString(ACSHELL_STR_WAIT_FOR_ACTIVATION, nil);
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            [self userDidAcknowledge:alert returnCode:returnCode];
        }];
    } else {
        [pages selectNextTabViewItem: sender];
    }
}

- (IBAction) userDidClickBack: (id) sender {
    // TODO: find a better way to check for the first page
    if ([backButton.title isEqual: NSLocalizedString(ACSHELL_STR_QUIT, nil)]) {
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    } else {
        [pages selectPreviousTabViewItem: sender];
    }
}

- (IBAction) userDidChangeServerDiscoveryMode: (id) sender {
    int selectedCellIndex = [[sender selectedCell] tag];
    [rsyncSourceEntry setEnabled: selectedCellIndex == 1];
    NSIndexSet * selectedServer = [bonjourServerList selectionIndexes];
    if (selectedCellIndex == 0 && [selectedServer count] == 0 && [bonjourLibraries count] > 0) {
        [bonjourServerList setSelectionIndexes: [NSIndexSet indexSetWithIndex: 0]];
        selectedServer = [bonjourServerList selectionIndexes];
    }
    [nextButton setEnabled: (selectedCellIndex == 1 && [[rsyncSourceEntry stringValue] length] > 0) || 
                            (selectedCellIndex == 0 && [selectedServer count] > 0)];
}

- (IBAction) userDidChangeRsyncSource: (id) sender {
    [nextButton setEnabled: [[rsyncSourceEntry stringValue] length] > 0];
}

- (IBAction) userDidSendEmail: (id) sender {
    [nextButton setEnabled: [sender state]];
}

-(void) userDidAcknowledge:(NSAlert *)sheet returnCode:(NSInteger)returnCode {
    [delegate setupDidFinish: self];
    [self close];
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

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([object isEqual: bonjourServerList]) {
        NSIndexSet * indices = [bonjourServerList selectionIndexes];
        [discoveryModeButtons selectCellWithTag: 0];
        [nextButton setEnabled: [indices count] > 0];
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
        case SETUP_PAGE_SUBSCRIBE_LIBRARY:
            [self setupSubscritptionPage];
            break;
        case SETUP_PAGE_SEND_MAIL:
            [self setupSendMailPage];
            break;
        default:
            break;
    }
}

- (void) setupSshIdentityPage {
    [self updatePublicKeyList];
}

- (void) setupSubscritptionPage {
    [nextButton setEnabled: NO];
    [emailSendToggle setState: NO];
    
    if ( ! bonjourBrowserRunning) {
        [bonjourBrowser searchForServicesOfType: ACSHELL_BONJOUR_TYPE inDomain: @""];
    }
    if ([bonjourLibraries count] > 0) {
        NSIndexSet * selection = [bonjourServerList selectionIndexes];
        if ([selection count] == 0) {
            [bonjourServerList setSelectionIndexes: [NSIndexSet indexSetWithIndex: 0]];
        } else {
            [nextButton setEnabled: YES];
        }
    }
}

- (void) setupSendMailPage {
    [nextButton setEnabled: [emailSendToggle state]];
    NSString * libraryName = NSLocalizedString(ACSHELL_STR_UNKNOWN, nil);
    NSString * adminAddress = NSLocalizedString(ACSHELL_STR_UNKNOWN, nil);
    if ([[discoveryModeButtons selectedCell] tag] == 0) {
        NSIndexSet * selection = [bonjourServerList selectionIndexes];
        if ([selection count] == 0) {
            NSLog(@"Error: no server selected.");
            return;
        }
        LibraryServer * server = [bonjourLibraries objectAtIndex: [selection firstIndex]];
        libraryName = server.name;
        adminAddress = server.administratorAddress;
    }

    [libraryNameLabel setStringValue: libraryName];
    [administratorAddressLabel setStringValue: adminAddress];

    SshIdentityFile * identity = [[publicKeyArrayController selectedObjects] objectAtIndex: 0];
    publicKeyDraglet.filename = identity.path;
    
}

- (IBAction) openMailTemplate: (id) sender {
    NSString * adminAddress = NSLocalizedString(ACSHELL_STR_UNKNOWN, nil);
    NSString * subject = [NSString stringWithFormat: @"ACShell library access"];
    NSString * body = [NSString stringWithFormat: @"Hi,\nI need to access the presentation library.\n Here is my public key:\n"];

    if ([[discoveryModeButtons selectedCell] tag] == 0) {
        NSIndexSet * selection = [bonjourServerList selectionIndexes];
        if ([selection count] == 0) {
            NSLog(@"Error: no server selected.");
            return;
        }
        LibraryServer * server = [bonjourLibraries objectAtIndex: [selection firstIndex]];
        NSString *libraryName = server.name;
        adminAddress = server.administratorAddress;
        subject = [server.keyRequestEmailSubject stringByReplacingOccurrencesOfString: @"%n" withString: libraryName];
        body = [server.keyRequestEmailBody stringByReplacingOccurrencesOfString: @"%n" withString: libraryName];
    }
        
    NSString * mailToURL = [NSString stringWithFormat: @"mailto:%@?subject=%@&body=%@",
                            adminAddress,
                            [subject stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
                            [body stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: mailToURL]];
    
}

- (void) updatePublicKeyList {
    [publicKeys removeAllObjects];
    NSString * sshDir = sshDirString();
    NSArray * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: sshDir error: nil];
    NSArray * publicKeyFiles = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.pub'"]];
    [self willChangeValueForKey: @"publicKeys"];
    for (NSString * file in publicKeyFiles) {
        NSString * path = [sshDir stringByAppendingPathComponent: file];
        [publicKeyArrayController addObject: [[SshIdentityFile alloc] initWithPath: path]];
    }
    [self didChangeValueForKey: @"publicKeys"];
    
    [nextButton setEnabled: [publicKeyArrayController selectionIndex] != NSNotFound];
    BOOL idFileExists = [[NSFileManager defaultManager] fileExistsAtPath: sshPublicKeyFilename() isDirectory: nil];
    [generateSshKeysButton setEnabled: ! idFileExists];
    
}

- (void) publicKeySelectionDidChange: (NSNotification *) notification {
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
    NSTask * sshTask = [[NSTask alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSshKeygen:)
												 name:NSTaskDidTerminateNotification object:sshTask];

    [sshTask setLaunchPath: @"/usr/bin/ssh-keygen"];
    [sshTask setArguments: args];
    self.sshKeygenTask = sshTask;
    [self.sshKeygenTask launch];
}

- (void) didFinishSshKeygen: (NSNotification*) notification {
    [self updatePublicKeyList];
    [sshKeygenSpinner setHidden: YES];
    [sshKeygenSpinner stopAnimation: nil];
}


#pragma mark -
#pragma mark NSNetServiceBrowserDelegate Protocol Methods
- (void) netServiceBrowserWillSearch: (NSNetServiceBrowser*) netServiceBrowser {
    bonjourBrowserRunning = YES;
}

- (void) netServiceBrowserDidStopSearch: (NSNetServiceBrowser*) netServiceBrowser {
    bonjourBrowserRunning = NO;
}


- (void) netServiceBrowser: (NSNetServiceBrowser*) browser 
              didNotSearch: (NSDictionary*) errorDict
{
    NSLog(@"Failed to browse service: %@", errorDict);
}

- (void) netServiceBrowser: (NSNetServiceBrowser*) browser
            didFindService: (NSNetService*) aNetService
                moreComing: (BOOL) moreComing
{
    [bonjourLibrariesArrayController addObject: [[LibraryServer alloc] initWithNetService: aNetService]];
    NSIndexSet * selection = [bonjourServerList selectionIndexes];
    if ([selection count] == 0) {
        [bonjourServerList setSelectionIndexes: [NSIndexSet indexSetWithIndex: 0]];
    }
}

- (void) netServiceBrowser: (NSNetServiceBrowser*) browser
          didRemoveService: (NSNetService*) aNetService
                moreComing: (BOOL) moreComing
{
    for (LibraryServer * server in bonjourLibraries) {
        if ([server.netService isEqual: aNetService]) {
            [bonjourLibrariesArrayController removeObject: server];
            break;
        }
    }
}

- (void) writeUserDefaults {
    NSString * rsyncSource;
    
    if ([[discoveryModeButtons selectedCell] tag] == 0) {
        NSIndexSet * selection = [bonjourServerList selectionIndexes];
        if ([selection count] == 0) {
            NSLog(@"Error: no server selected.");
            return;
        }
        LibraryServer * server = [bonjourLibraries objectAtIndex: [selection firstIndex]];
        
        rsyncSource = server.rsyncSource;
        
        [[NSUserDefaults standardUserDefaults] setValue: server.readUser forKey: ACSHELL_DEFAULT_KEY_RSYNC_READ_USER];
        [[NSUserDefaults standardUserDefaults] setValue: server.writeUser forKey: ACSHELL_DEFAULT_KEY_RSYNC_WRITE_USER];        
    } else {
        rsyncSource = [rsyncSourceEntry stringValue];
        [[NSUserDefaults standardUserDefaults] setValue: ACSHELL_RSYNC_READ_USER_DEFAULT forKey: ACSHELL_DEFAULT_KEY_RSYNC_READ_USER];
        [[NSUserDefaults standardUserDefaults] setValue: ACSHELL_RSYNC_WRITE_USER_DEFAULT forKey: ACSHELL_DEFAULT_KEY_RSYNC_WRITE_USER];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue: rsyncSource forKey: ACSHELL_DEFAULT_KEY_RSYNC_SOURCE];
}

#pragma mark -
#pragma mark Helpers
NSString * sshDirString() {
    return [@"~/.ssh/" stringByExpandingTildeInPath];
}

NSString * sshPrivateKeyFilename() {
    return [sshDirString() stringByAppendingPathComponent: @"id_rsa"];
}

NSString * sshPublicKeyFilename() {
    return [sshPrivateKeyFilename() stringByAppendingPathExtension: @"pub"];
}

@end
