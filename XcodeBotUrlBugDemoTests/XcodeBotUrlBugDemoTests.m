//
//  XcodeBotUrlBugDemoTests.m
//  XcodeBotUrlBugDemoTests
//
//  Created by Dov Frankel on 12/30/14.
//  Copyright (c) 2014 Abbey Code. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface XcodeBotUrlBugDemoTests : XCTestCase

@end

@implementation XcodeBotUrlBugDemoTests

- (void)testBookmarks
{
    // Create testing directory
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL useHomeDir = [[[NSProcessInfo processInfo].environment objectForKey:@"UNIT_TEST_IN_HOME_DIR"] length] > 0;
    NSString *sourceDir = [fm currentDirectoryPath];
    NSString *testingDirPath = [(useHomeDir ? NSHomeDirectory() : sourceDir) stringByAppendingPathComponent:@"~testing dir"];
    
    NSLog(@"Using test directory: %@", testingDirPath);
    
    if ([fm fileExistsAtPath:testingDirPath]) {
        [fm removeItemAtPath:testingDirPath error:NULL];
    }
    
    [fm createDirectoryAtPath:testingDirPath
  withIntermediateDirectories:YES
                   attributes:nil
                        error:NULL];

    // Create file to create bookmark to
    NSString *bookmarkedFilePath = [testingDirPath stringByAppendingPathComponent:@"fileToBookmark.txt"];
    [fm createFileAtPath:bookmarkedFilePath
                contents:nil
              attributes:nil];
    
    XCTAssertTrue([fm fileExistsAtPath:bookmarkedFilePath], @"Failed to create %@", bookmarkedFilePath);
    
    NSURL *originalURL = [NSURL fileURLWithPath:bookmarkedFilePath];

    // Create file to create bookmark relative to
    NSString *relativeFilePath = [testingDirPath stringByAppendingPathComponent:@"relativeToFile.txt"];
    [fm createFileAtPath:relativeFilePath
                contents:nil
              attributes:nil];
    
    XCTAssertTrue([fm fileExistsAtPath:relativeFilePath], @"Failed to create %@", relativeFilePath);

    // Create a document-scoped bookmark
    NSError *docScopedError = nil;
    NSURL *relativeToURL = [NSURL fileURLWithPath:relativeFilePath];
    NSData *bookmark = [originalURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                             includingResourceValuesForKeys:nil
                                              relativeToURL:relativeToURL
                                                      error:&docScopedError];
    
    // Assert everything went well
    XCTAssertNil(docScopedError, @"Error while creating document-scoped bookmark from URL:\n%@\nrelative to: %@",
                 originalURL, relativeToURL);
    XCTAssertNotNil(bookmark, @"No bookmark created to URL:\n%@\nrelative to: %@",
                 originalURL, relativeToURL);
}

@end
