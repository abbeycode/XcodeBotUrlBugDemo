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
    NSString *sourceDir = [fm currentDirectoryPath];
    NSString *testingDir = [sourceDir stringByAppendingPathComponent:@"~testing dir"];

    if ([fm fileExistsAtPath:testingDir]) {
        [fm removeItemAtPath:testingDir error:NULL];
    }
    
    [fm createDirectoryAtPath:testingDir
  withIntermediateDirectories:NO
                   attributes:nil
                        error:NULL];

    // Create file to create bookmark to
    NSString *bookmarkedFilePath = [testingDir stringByAppendingPathComponent:@"fileToBookmark.txt"];
    [fm createFileAtPath:bookmarkedFilePath
                contents:nil
              attributes:nil];
    NSURL *originalURL = [NSURL fileURLWithPath:bookmarkedFilePath];

    // Create file to create bookmark relative to
    NSString *relativeFilePath = [testingDir stringByAppendingPathComponent:@"relativeToFile.txt"];
    [fm createFileAtPath:relativeFilePath
                contents:nil
              attributes:nil];

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
