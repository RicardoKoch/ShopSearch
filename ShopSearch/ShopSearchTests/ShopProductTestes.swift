//
//  ShopProductTestes.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/4/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import XCTest
@testable import ShopSearch

class ShopProductTestes: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchProduct() {
        
        let expect = self.expectationWithDescription("Empty Search Test")
        NSLog("Empty Search Test", "")
        
        ShopSearch.sharedInstance().fetchProduct("11557001497517563767") { (product, success) -> (Void) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertNotNil(product, "Could not find the expected product")
            XCTAssertTrue(NSThread.isMainThread(), "Should be on main thread")
            
            NSLog("\(product)", "")
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
