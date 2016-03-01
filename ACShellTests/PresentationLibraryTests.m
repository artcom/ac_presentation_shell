//
//  PresentationLibraryTests.m
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

@interface PresentationLibraryTests : XCTestCase
@property (nonatomic) NSString *libraryXML;
@property (nonatomic) NSString *libraryPath;
@property (nonatomic) NSString *storageLibraryPath;
@property (nonatomic) PresentationLibrary *library;
@property (nonatomic) NSString *presentationId;
@end

@implementation PresentationLibraryTests

- (void)setUp
{
    [super setUp];
    
    _libraryXML = [[NSBundle bundleForClass:self.class] pathForResource:@"library" ofType:@"xml"];
    _libraryPath = [self.libraryXML stringByDeletingLastPathComponent];
    _storageLibraryPath = [NSString stringWithFormat:@"%@acshelltests/library", NSTemporaryDirectory()];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.storageLibraryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    _library = [PresentationLibrary new];
    [self.library loadXmlLibraryFromDirectory:self.libraryPath];
    
    _presentationId = @"B2EE53BC-85E3-4024-B232-21A5C04AD8CA";
}

- (void)tearDown
{
    self.library = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.storageLibraryPath error:nil];
    
    [super tearDown];
}

- (void)testLibraryHasCategories
{
    XCTAssertEqual(self.library.categories.count, 3, @"Library should contain 3 categories.");
    
    LibraryCategory *categoryZero = self.library.categories[0];
    LibraryCategory *categoryOne = self.library.categories[1];
    LibraryCategory *categoryTwo = self.library.categories[2];
    
    XCTAssertEqual(categoryZero.index.integerValue, 0, @"Category zero should have index of 0");
    XCTAssertEqualObjects(categoryZero.title, @"zero", @"Category zero should have valid a title.");
    XCTAssertEqualObjects(categoryZero.assets, @"000/zero", @"Category zero should have a valid asset directory path.");
    
    XCTAssertEqual(categoryOne.index.integerValue, 1, @"Category one should have index of 1");
    XCTAssertEqualObjects(categoryOne.title, @"one", @"Category one should have valid a title.");
    XCTAssertEqualObjects(categoryOne.assets, @"001/one", @"Category one should have a valid asset directory path.");
    
    XCTAssertEqual(categoryTwo.index.integerValue, 2, @"Category two should have index of 2");
    XCTAssertEqualObjects(categoryTwo.title, @"two", @"Category two should have valid a title.");
    XCTAssertEqualObjects(categoryTwo.assets, @"002/two", @"Category two should have a valid asset directory path.");
}

- (void)testLibraryHasPresentations
{
    XCTAssertNotNil(self.library.library, @"Library should not be nil.");
    XCTAssertEqual(self.library.library.children.count, 2, @"Count should be 2.");
    
    ACShellCollection *root = self.library.library;
    XCTAssertEqual(root.name, @"root", @"Collection should be named 'root'.");
    XCTAssertEqual(root.presentations.count, 0, @"Collection should contain 0 presentations.");
    
    ACShellCollection *library = root.children.firstObject;
    XCTAssertEqual(library.name, @"Library", @"Collection should be named 'Library'.");
    
    NSPredicate *allCollection = [NSPredicate predicateWithFormat:@"name = 'All'"];
    ACShellCollection *all = [library.children filteredArrayUsingPredicate:allCollection].firstObject;
    XCTAssertEqual(all.name, @"All", @"Collection should be named 'All'.");
    XCTAssertEqual(all.presentations.count, 5, @"Collection should contain 5 presentations.");
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"presentationId = %@", self.presentationId];
    Presentation *presentation = [all.presentations filteredArrayUsingPredicate:predicate].firstObject;
    XCTAssertEqualObjects(presentation.title, @"OBSERVATION DECK", @"Presentation should have a valid title.");
    XCTAssertEqual(presentation.categories.count, 3, @"Presentation should have 3 categories set.");
}

- (void)testLibraryHasHighlightedPresentations
{
    ACShellCollection *root = self.library.library;
    ACShellCollection *library = root.children.firstObject;
    
    NSPredicate *highlightsCollection = [NSPredicate predicateWithFormat:@"name = 'Highlights'"];
    ACShellCollection *highlights = [library.children filteredArrayUsingPredicate:highlightsCollection].firstObject;
    XCTAssertEqual(highlights.name, @"Highlights", @"Collection should be named 'Highlights'.");
    XCTAssertEqual(highlights.presentations.count, 1, @"Collection should contain 1 presentation.");
    
    Presentation *presentation = highlights.presentations.firstObject;
    XCTAssertEqualObjects(presentation.title, @"KINETIC SCULPTURE", @"Presentation should have a valid title.");
    XCTAssertEqual(presentation.categories.count, 1, @"Presentation should have 1 category set.");
}

- (void)testSerializeLibraryXML
{
    ACShellCollection *root = self.library.library;
    ACShellCollection *library = root.children.firstObject;
    
    NSPredicate *allCollection = [NSPredicate predicateWithFormat:@"name = 'All'"];
    ACShellCollection *all = [library.children filteredArrayUsingPredicate:allCollection].firstObject;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"presentationId = %@", self.presentationId];
    Presentation *presentation = [all.presentations filteredArrayUsingPredicate:predicate].firstObject;
    presentation.title = @"THE NEW TITLE";
    presentation.categories = @[@2, @1];
    
    self.library.libraryDirPath = self.storageLibraryPath;
    [self.library saveXmlLibrary];
    
    _library = [PresentationLibrary new];
    [self.library loadXmlLibraryFromDirectory:self.storageLibraryPath];
    
    XCTAssertEqual(self.library.categories.count, 3, @"Library should contain 3 categories.");
    
    LibraryCategory *categoryZero = self.library.categories[0];
    LibraryCategory *categoryOne = self.library.categories[1];
    LibraryCategory *categoryTwo = self.library.categories[2];
    
    XCTAssertEqual(categoryZero.index.integerValue, 0, @"Category zero should have index of 0");
    XCTAssertEqualObjects(categoryZero.title, @"zero", @"Category zero should have valid a title.");
    XCTAssertEqualObjects(categoryZero.assets, @"000/zero", @"Category zero should have a valid asset directory path.");
    
    XCTAssertEqual(categoryOne.index.integerValue, 1, @"Category one should have index of 1");
    XCTAssertEqualObjects(categoryOne.title, @"one", @"Category one should have valid a title.");
    XCTAssertEqualObjects(categoryOne.assets, @"001/one", @"Category one should have a valid asset directory path.");
    
    XCTAssertEqual(categoryTwo.index.integerValue, 2, @"Category two should have index of 2");
    XCTAssertEqualObjects(categoryTwo.title, @"two", @"Category two should have valid a title.");
    XCTAssertEqualObjects(categoryTwo.assets, @"002/two", @"Category two should have a valid asset directory path.");
    
    root = self.library.library;
    library = root.children.firstObject;
    all = [library.children filteredArrayUsingPredicate:allCollection].firstObject;
    presentation = [all.presentations filteredArrayUsingPredicate:predicate].firstObject;
    XCTAssertEqualObjects(presentation.title, @"THE NEW TITLE", @"Presentation should have a valid title.");
    XCTAssertEqual(presentation.categories.count, 2, @"Presentation should have 2 categories set.");
}

@end
