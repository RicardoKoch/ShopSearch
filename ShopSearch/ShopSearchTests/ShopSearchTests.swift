//
//  ShopSearchTests.swift
//  ShopSearchTests
//
//  Created by Ricardo Koch on 4/2/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import XCTest
@testable import ShopSearch

class ShopSearchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: CategoriesArchiveKey)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: CategoriesArchiveKey)
    }
    
    func testBasicSearch() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let expect = self.expectationWithDescription("Basic Search Test")
        NSLog("Basic Search Test", "")
        
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s Plus 128gb") {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertNotEqual(products?.count, 0, "Should NOT find 0 products with query")
            XCTAssertTrue(NSThread.isMainThread(), "Should be on main thread")
            
            NSLog("Basic Search Test - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            expect.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60) { (error:NSError?) in
            if error != nil {
                NSLog("Basic Search Test - FAIL with timeout", "")
            }
            else {
                NSLog("Basic Search Test - COMPLETE", "")
            }
        }
        
    }
    
    func testEmptySearch() {
        
        
        let expect = self.expectationWithDescription("Empty Search Test")
        NSLog("Empty Search Test", "")
        
        ShopSearch.sharedInstance().search(keywords:"") {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertEqual(products?.count, 0, "Should find 0 products with empty query")
            XCTAssertTrue(NSThread.isMainThread(), "Should be on main thread")
            
            NSLog("Empty Search Test - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            expect.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60) { (error:NSError?) in
            if error != nil {
                NSLog("Empty Search Test - FAIL with timeout", "")
            }
            else {
                NSLog("Empty Search Test - COMPLETE", "")
            }
        }
        
    }
    
    func testStressTypeSearch() {
        
        let expect = self.expectationWithDescription("TestStressTypeSearch")
        
        var callbackCount = 0
        let callback = {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertTrue(NSThread.isMainThread(), "Should be on main thread")
            
            NSLog("TestStressTypeSearch - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            callbackCount += 1
            if callbackCount == 11 {
                expect.fulfill()
            }
        }
        
        ShopSearch.sharedInstance().search(keywords:"iP", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPh", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPho", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhon", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s 1", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s 12", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s 128", completionBlock: callback)
        ShopSearch.sharedInstance().search(keywords:"iPhone 6s 128GB", completionBlock: callback)
        
        self.waitForExpectationsWithTimeout(120) { (error:NSError?) in
            if error != nil {
                NSLog("TestStressTypeSearch - FAIL with timeout", "")
            }
            else {
                NSLog("TestStressTypeSearch - COMPLETE", "")
            }
        }
    }
    
    func testExceptionSearch1() {

        let expect = self.expectationWithDescription("ExceptionSearch1 Search Test")
        
        ShopSearch.sharedInstance().search(keywords:"Appl") {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertNotEqual(products?.count, 0, "Should NOT find 0 products with query")
            XCTAssertTrue(NSThread.isMainThread(), "Should be on main thread")
            
            NSLog("ExceptionSearch1 Search Test - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            expect.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60) { (error:NSError?) in
            if error != nil {
                NSLog("ExceptionSearch1 Search Test - FAIL with timeout", "")
            }
            else {
                NSLog("ExceptionSearch1 Search Test - COMPLETE", "")
            }
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}


extension ShopSearchTests {
    
    
    
}

