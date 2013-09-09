//
//  ACPresentationIndexTest.m
//  ACShell
//
//  Created by Patrick Juchli on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSFileManager-DirectoryHelper.h"
#import "ACPresentationLibraryIndex.h"

@interface ACPresentationIndexTest : XCTestCase
@property (nonatomic, strong) ACPresentationLibraryIndex *presentationIndex;
@end

@implementation ACPresentationIndexTest

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"demo_library"];
    
    self.presentationIndex = [[ACPresentationLibraryIndex alloc] initWithPath:path];
    [self.presentationIndex release];
}

- (void)tearDown
{
    [super tearDown];
    self.presentationIndex = nil;
}

- (void)testSetup
{
    XCTAssertNotNil(self.presentationIndex, @"ACPresentationIndex not initialized");
}

- (void)testOpenIndex {
    //[self.presentationIndex openIndex];
    SKIndexRef indexRef = [self.presentationIndex index];
    XCTAssertNotEqual(indexRef, NULL, @"SKIndexRef is null");
}

- (void)testAnalysisProperties {
    //[self.presentationIndex openIndex];
    SKIndexRef indexRef = [self.presentationIndex index];
    NSDictionary *dict = (NSDictionary *)SKIndexGetAnalysisProperties(indexRef);
    XCTAssertNotNil(dict, @"No text analysis properties specified");
    
    // Proximity searching needs to be enabled
    NSNumber *proximitySearching = dict[@"kSKProximitySearching"];
    XCTAssertNotNil(proximitySearching, @"kSKProximitySearching not specified");
    XCTAssertEqual(proximitySearching, @1, @"kSKProximitySearching not enabled");
}

- (void)testIndexing {
    [self.presentationIndex resetIndex];
    [self.presentationIndex indexFilesWithExtension:@"key"];
    // TODO Actually test something
}

- (void)testSearch {
    [self.presentationIndex find:@"BMW"];
}

@end
