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
        
        UserDefaults.standard.set(nil, forKey: CategoriesArchiveKey)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        UserDefaults.standard.set(nil, forKey: CategoriesArchiveKey)
    }
	
	func testSingleSearch() {
		
		let expect = self.expectation(description: "Single Search Test")
		
		ShopSearch.shared().search(keywords:"DJI Mavic Pro") {
			(products:[GoogleProduct]?, success:Bool) in
			
			XCTAssertTrue(success == true, "Search failed to execute")
			XCTAssertNotEqual(products?.count, 0, "Should NOT find 0 products with query")
			XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
			
			NSLog("Basic Search Test - Found \(products?.count) products", "")
			//NSLog("\(products)", "")
			expect.fulfill()
		}
		
		self.waitForExpectations(timeout: 60) { (error:Error?) in
			if error != nil {
				NSLog("Basic Search Test - FAIL with timeout", "")
			}
			else {
				NSLog("Basic Search Test - COMPLETE", "")
			}
		}
		
		
	}
	
    func testMultipleSearch() {
		
		let searchTerms = ["iPhone 6s Plus 128gb", "Android", "Galaxy" , "DJI", "DJI Mavic Pro"]
		
		for term in searchTerms {
		
			let expect = self.expectation(description: "Multiple Search Test")
			
			ShopSearch.shared().search(keywords:term) {
				(products:[GoogleProduct]?, success:Bool) in
				
				XCTAssertTrue(success == true, "Search failed to execute")
				XCTAssertNotEqual(products?.count, 0, "Should NOT find 0 products with query")
				XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
				
				NSLog("Basic Search Test - Found \(products?.count) products", "")
				//NSLog("\(products)", "")
				expect.fulfill()
			}
			
			self.waitForExpectations(timeout: 60) { (error:Error?) in
				if error != nil {
					NSLog("Basic Search Test - FAIL with timeout", "")
				}
				else {
					NSLog("Basic Search Test - COMPLETE", "")
				}
			}
			
		}
    }
	
    func testEmptySearch() {
		
		
        let expect = self.expectation(description: "Empty Search Test")
        NSLog("Empty Search Test", "")
        
        ShopSearch.shared().search(keywords:"") {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertEqual(products?.count, 0, "Should find 0 products with empty query")
            XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
            
            NSLog("Empty Search Test - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 60) { (error:Error?) in
            if error != nil {
                NSLog("Empty Search Test - FAIL with timeout", "")
            }
            else {
                NSLog("Empty Search Test - COMPLETE", "")
            }
        }
        
    }
    
    func testStressTypeSearch() {
        
        let expect = self.expectation(description: "TestStressTypeSearch")
        
        var callbackCount = 0
        let callback = {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
            
            NSLog("TestStressTypeSearch - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            callbackCount += 1
            if callbackCount == 7 {
                expect.fulfill()
            }
        }
        
        ShopSearch.shared().search(keywords:"iP", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPho", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPhon", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPhone 6", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPhone 6s 1", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPhone 6s 12", completionBlock: callback)
        ShopSearch.shared().search(keywords:"iPhone 6s 128GB", completionBlock: callback)
        
        self.waitForExpectations(timeout: 200) { (error:Error?) in
            if error != nil {
                NSLog("TestStressTypeSearch - FAIL with timeout", "")
            }
            else {
                NSLog("TestStressTypeSearch - COMPLETE", "")
            }
        }
    }
    
    func testExceptionSearch1() {

        let expect = self.expectation(description: "ExceptionSearch1 Search Test")
        
        ShopSearch.shared().search(keywords:"Appl") {
            (products:[GoogleProduct]?, success:Bool) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertNotEqual(products?.count, 0, "Should NOT find 0 products with query")
            XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
            
            NSLog("ExceptionSearch1 Search Test - Found \(products?.count) products", "")
            //NSLog("\(products)", "")
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 60) { (error:Error?) in
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


extension ShopSearchTests {
    
    
    
}

