//
//  PresentationTableViewController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface PresentationTableViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSMutableArray *currentPresentationList;

@property (weak, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (weak) IBOutlet NSTableView *presentationTable;

@end

NS_ASSUME_NONNULL_END
