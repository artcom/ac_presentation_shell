//
//  ACShellTests.m
//  ACShellTests
//
//  Created by Julian Krumow on 01.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PresentationLibrary.h"
#import "LibraryCategory.h"
#import "ACShellCollection.h"
#import "Presentation.h"

@interface ACShellTests : XCTestCase
@property (nonatomic) NSString *libraryXML;
@property (nonatomic) NSString *libraryPath;
@property (nonatomic) NSString *storageLibraryPath;
@property (nonatomic) PresentationLibrary *library;

@end

@implementation ACShellTests

- (void)setUp
{
    [super setUp];
    
    _libraryXML = [[NSBundle bundleForClass:self.class] pathForResource:@"library" ofType:@"xml"];
    _libraryPath = [self.libraryXML stringByDeletingLastPathComponent];
    _storageLibraryPath = [NSString stringWithFormat:@"%@/acshelltests/library", NSTemporaryDirectory()];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.storageLibraryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    _library = [PresentationLibrary new];
    [self.library loadXmlLibraryFromDirectory:self.libraryPath];
}

- (void)tearDown
{
    self.library = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.storageLibraryPath error:nil];
    
    [super tearDown];
}

- (void)testIntializeLibrary
{
    XCTAssertEqual(self.library.categories.count, 3, @"Library shoul contain 3 categories.");
    
    LibraryCategory *category = self.library.categories.lastObject;
    XCTAssertEqual(category.index, 2, @"Category should have index of 2");
    XCTAssertEqualObjects(category.title, @"research", @"Category should have valid title.");
    XCTAssertEqualObjects(category.assets, @"002/research", @"Category should have valid asset directory path.");
    
    XCTAssertNotNil(self.library.library, @"Library should not be nil.");
    XCTAssertEqual(self.library.library.children.count, 2, @"Count should be 2.");
    
    ACShellCollection *root = self.library.library;
    XCTAssertEqual(root.name, @"root", @"Collection should be named 'root'.");
    XCTAssertEqual(root.presentations.count, 0, @"Collection should contain 0 presentations.");
    
    ACShellCollection *library = root.children.firstObject;
    XCTAssertEqual(library.name, @"Library", @"Collection should be named 'Library'.");
    
    ACShellCollection *all = library.children.firstObject;
    XCTAssertEqual(all.name, @"All", @"Collection should be named 'All'.");
    XCTAssertEqual(all.presentations.count, 46, @"Collection should contain 46 presentations.");
    
    Presentation *presentation = all.presentations.lastObject;
    XCTAssertEqualObjects(presentation.title, @"THE FORMATION OF HAMBURG", @"Presentation should have valid title.");
    XCTAssertEqual(presentation.categories.count, 1, @"Presentation should have categories set.");
}

- (void)testSerializeLibrary
{
    ACShellCollection *root = self.library.library;
    ACShellCollection *library = root.children.firstObject;
    ACShellCollection *all = library.children.firstObject;
    Presentation *presentation = all.presentations.lastObject;
    
    presentation.title = @"THE NEW TITLE OF HAMBURG";
    presentation.categories = @[@1, @2];
    
    self.library.libraryDirPath = self.storageLibraryPath;
    [self.library saveXmlLibrary];
    
    
    _library = [PresentationLibrary new];
    [self.library loadXmlLibraryFromDirectory:self.storageLibraryPath];
    
    XCTAssertEqual(self.library.categories.count, 3, @"Library shoul contain 3 categories.");
    
    LibraryCategory *category = self.library.categories.lastObject;
    XCTAssertEqual(category.index, 2, @"Category should have index of 2");
    XCTAssertEqualObjects(category.title, @"research", @"Category should have valid title.");
    XCTAssertEqualObjects(category.assets, @"002/research", @"Category should have valid asset directory path.");
    
    root = self.library.library;
    library = root.children.firstObject;
    all = library.children.firstObject;
    presentation = all.presentations.lastObject;
    
    XCTAssertEqualObjects(presentation.title, @"THE NEW TITLE OF HAMBURG", @"Presentation should have valid title.");
    XCTAssertEqual(presentation.categories.count, 2, @"Presentation should have categories set.");
}

@end
