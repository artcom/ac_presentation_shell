//
//  ACPresentationIndexTest.m
//  ACShell
//
//  Created by Patrick Juchli on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSFileManager-DirectoryHelper.h"
#import "ACPresentationIndex.h"

@interface ACPresentationIndexTest : XCTestCase
@property (nonatomic, strong) ACPresentationIndex *presentationIndex;
@end

@implementation ACPresentationIndexTest

- (void)setUp
{
    [super setUp];
    
    NSString *path = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"demo_library"];
    
    self.presentationIndex = [[ACPresentationIndex alloc] initWithPath:path];
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
    [self.presentationIndex openIndex];
    SKIndexRef indexRef = [self.presentationIndex skIndexRef];
    XCTAssertNotEqual(indexRef, NULL, @"SKIndexRef is null");
}

- (void)testAnalysisProperties {
    [self.presentationIndex openIndex];
    SKIndexRef indexRef = [self.presentationIndex skIndexRef];
    NSDictionary *dict = (NSDictionary *)SKIndexGetAnalysisProperties(indexRef);
    XCTAssertNotNil(dict, @"No text analysis properties specified");
    
    // Proximity searching needs to be enabled
    NSNumber *proximitySearching = dict[@"kSKProximitySearching"];
    XCTAssertNotNil(proximitySearching, @"kSKProximitySearching not specified");
    XCTAssertEqual(proximitySearching, @1, @"kSKProximitySearching not enabled");
}

//- (void)testAnalysisProperties {
//    [self.presentationIndex openIndex];
//}

@end
