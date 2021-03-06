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
        
        let expect = self.expectation(description: "Product Fetch Test")
        
        ShopSearch.shared().fetchProduct("11557001497517563767") { (product, success) -> (Void) in
            
            XCTAssertTrue(success == true, "Search failed to execute")
            XCTAssertNotNil(product, "Could not find the expected product")
            XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
			XCTAssertTrue(product?.vendors.count ?? 0 >= 1, "Test failed to execute")
			XCTAssertTrue(product?.models.count ?? 0 > 10, "Test failed to execute")
			XCTAssertEqual(product?.category?.categoryId ?? "", "267", "Test failed to execute")
			XCTAssertNotEqual(product?.title.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.productId.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.getPriceTag()?.length ?? 0, 0, "Test failed to execute")
			
            NSLog("\(String(describing: product))", "")
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 60) { (error:Error?) in
            if error != nil {
                NSLog("FAIL with timeout", "")
            }
        }
        
    }
	
	func testFetchProduct2() {

		let expect = self.expectation(description: "Product Fetch Test")
		
		ShopSearch.shared().fetchProduct("224971304856227477") { (product, success) -> (Void) in
			
			XCTAssertTrue(success == true, "Search failed to execute")
			XCTAssertNotNil(product, "Could not find the expected product")
			XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
			XCTAssertTrue(product?.vendors.count ?? 0 > 0, "Test failed to execute")
			XCTAssertTrue(product?.models.count ?? 0 > 0, "Test failed to execute")
			XCTAssertTrue(product?.category?.categoryId == "267", "Test failed to execute")
			XCTAssertTrue(product?.category?.name == "Mobile Phones", "Test failed to execute")
			XCTAssertNotEqual(product?.category, nil, "Test failed to execute")
			XCTAssertNotEqual(product?.title.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.productId.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.getPriceTag()?.length ?? 0, 0, "Test failed to execute")
			
			NSLog("\(String(describing: product))", "")
			expect.fulfill()
		}
		
		self.waitForExpectations(timeout: 60) { (error:Error?) in
			if error != nil {
				NSLog("FAIL with timeout", "")
			}
		}
	}
	
	func testFetchProduct3() {
		
		let expect = self.expectation(description: "Product Fetch Test")
		
		ShopSearch.shared().fetchProduct("14527021981700499570") { (product, success) -> (Void) in
			
			XCTAssertTrue(success == true, "Search failed to execute")
			XCTAssertNotNil(product, "Could not find the expected product")
			XCTAssertTrue(Thread.isMainThread, "Should be on main thread")
			XCTAssertTrue(product?.vendors.count ?? 0 > 0, "Test failed to execute")
			//THIS OBJECT HAS NO CATEGORY LINK. NEED to figure out a new way to get it.
			XCTAssertEqual(product?.category, nil, "Test failed to execute")
			XCTAssertNotEqual(product?.title.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.productId.characters.count ?? 0, 0, "Test failed to execute")
			XCTAssertNotEqual(product?.getPriceTag()?.length ?? 0, 0, "Test failed to execute")
			
			NSLog("\(String(describing: product))", "")
			expect.fulfill()
		}
		
		self.waitForExpectations(timeout: 60) { (error:Error?) in
			if error != nil {
				NSLog("FAIL with timeout", "")
			}
		}
	}

	
}
