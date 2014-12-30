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

- (void)testBookmarks {
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
    
    NSString *bookmarkedFilePath = [testingDir stringByAppendingPathComponent:@"fileToBookmark.txt"];
    [fm createFileAtPath:bookmarkedFilePath
                contents:nil
              attributes:nil];
    
    NSError *error = nil;
    NSURL *originalURL = [NSURL fileURLWithPath:bookmarkedFilePath];
    NSData *appScopedBookmark = [originalURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                                      includingResourceValuesForKeys:nil
                                                       relativeToURL:nil
                                                               error:&error];
    
    NSError *docScopedError = nil;
    BOOL isStale = NO;
    NSURL *url = [NSURL URLByResolvingBookmarkData:appScopedBookmark
                                           options:NSURLBookmarkResolutionWithSecurityScope
                                     relativeToURL:nil
                               bookmarkDataIsStale:&isStale
                                             error:&docScopedError];
    
    XCTAssertNil(error, @"Error while resolving app-scoped bookmark");
    
    NSString *relativeFilePath = [testingDir stringByAppendingPathComponent:@"relativeToFile.txt"];
    [fm createFileAtPath:relativeFilePath
                contents:nil
              attributes:nil];

    [url startAccessingSecurityScopedResource];
    
    NSURL *relativeToURL = [NSURL fileURLWithPath:relativeFilePath];
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                     includingResourceValuesForKeys:nil
                                      relativeToURL:relativeToURL
                                              error:&docScopedError];
    
    [url stopAccessingSecurityScopedResource];
    
    XCTAssertNil(docScopedError, @"Error while creating document-scoped bookmark from URL:\n%@\nrelative to: %@",
                 url, relativeToURL);
    XCTAssertNotNil(bookmark, @"No bookmark created to URL:\n%@\nrelative to: %@",
                 url, relativeToURL);
}

@end
