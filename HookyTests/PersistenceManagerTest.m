//
//  PersistenceManagerTest.m
//  Hooky
//
//  Created by Suewon Bahng on 3/17/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PersistenceManager.h"
#import "TestUtils.h"

@interface PersistenceManagerTest : XCTestCase<PersistenceManagerDelegate> {
    NSFileManager*      fm;
    PersistenceManager* pstMgr;
    NSString*           enclosingPath;
}
@end

@implementation PersistenceManagerTest

#pragma mark PersistenceManagerDelegate

- (NSString*)enclosingPath {
    XCTAssert(self->enclosingPath);
    return self->enclosingPath;
}

- (void)preload:(NSString *)storagePath {
}

- (void)presave:(NSString *)storagePath {
}

- (void)postsave:(NSString *)storagePath {
    XCTAssertEqual([self->fm fileExistsAtPath:storagePath], YES);
}

#pragma mark Helpers

+ (NSDictionary*)getTestData {
    static NSDictionary* data = nil;
    
    RUN_ONCE_BEGIN
        data = @{
                       @"${var:-default}" : @"expand to a default value if a variable is unset or empty",
                       @"${var-default}" : @"expand to a default value if a variable is unset",
                       @"${var:+alternate}" : @"expand to an alternative value if a variable is set or not empty",
                       @"${var:=default}" : @"assign the default value if a variable is unset or empty",
                       @"${var:?message}" : @"print message to the standard error and exit with a status of 1 if a variable is not set or empty",
                       @"${var?message}" : @"print message to the standard error and exit with a status of 1 if a variable is not set"
                       };
    RUN_ONCE_END
    
    return data;
}

#pragma mark Unit Test Code

- (void)setUp {
    [super setUp];
    
    self->fm = [NSFileManager defaultManager];
    
    self->enclosingPath = [NSString pathWithComponents:@[ NSTemporaryDirectory(), @"tmp" ]];
    
    self->pstMgr = [[PersistenceManager alloc] init];
    self->pstMgr.delegate = self;
}

- (void)tearDown {
    [TestUtils deleteFolder:self->enclosingPath];
    
    [super tearDown];
}

- (void)testIfItCanSaveWhenPrivateHomeDoesntExist {
    [TestUtils deleteFolder:self->enclosingPath];
    XCTAssertEqual([self->fm fileExistsAtPath:self->enclosingPath], NO);
    NSDictionary* data = [[self class] getTestData];
    XCTAssert(data && data.count);
    XCTAssertEqual([self->pstMgr save:data], true);
}

- (void)testIfItCanSaveWhenPrivateHomeDoesExist {
    XCTAssertEqual([TestUtils createFolder:self->enclosingPath], true);
    XCTAssertEqual([self->fm fileExistsAtPath:self->enclosingPath], YES);
    NSDictionary* data = [[self class] getTestData];
    XCTAssert(data && data.count);
    XCTAssertEqual([self->pstMgr save:data], true);
}

- (void)testIfItReturnsNilWhenDataStoreDoesntExist {
    [TestUtils deleteFolder:self->enclosingPath];
    XCTAssertEqual([self->fm fileExistsAtPath:self->enclosingPath], NO);
    XCTAssertEqual([self->pstMgr load], nil);
}

- (void)testLoadAndSaveCoherence {
    NSDictionary* data = [[self class] getTestData];
    XCTAssert(data && data.count);
    XCTAssertEqual([self->pstMgr save:data], true);
    NSDictionary* loadedData = [self->pstMgr load];
    XCTAssert(loadedData);
    XCTAssertEqualObjects(data, loadedData);
}

@end
