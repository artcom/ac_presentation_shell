//
//  ACSearchIndexResult.h
//  ACShell
//
//  Created by Patrick Juchli on 27.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSearchIndexResult : NSObject
@property (nonatomic, assign) SKDocumentID documentId;
@property (nonatomic, strong) NSURL *documentUrl;
@property (nonatomic, assign) float score;
@end
