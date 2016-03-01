//
//  ACShellTests.m
//  ACShellTests
//
//  Created by Julian Krumow on 01.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PresentationLibrary.h"

@interface ACShellTests : XCTestCase
@property (nonatomic) NSString *libraryPath;
@property (nonatomic) PresentationLibrary *library;

@end

@implementation ACShellTests

- (void)setUp
{
    [super setUp];
    
    _libraryPath = [[[NSBundle bundleForClass:self.class] pathForResource:@"library" ofType:@"xml"] stringByDeletingLastPathComponent];
    _library = [PresentationLibrary new];
    [self.library loadXmlLibraryFromDirectory:self.libraryPath];
}

- (void)tearDown
{
    
    [super tearDown];
}

- (void)testIntializeLibrary
{
    
}

@end
