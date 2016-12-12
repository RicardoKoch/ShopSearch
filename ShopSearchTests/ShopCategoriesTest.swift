//
//  ShopCategoriesTest.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/5/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import XCTest
@testable import ShopSearch

class ShopCategoriesTest: XCTestCase {
    
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
	
    func testCategoriesFetch() {
        
        NSLog("Fetch Google Categories", "")
        
        let ss = ShopSearch()
        //this will call fetch categories method on the constructor
        
        while !ss.initialized {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1) as Date)
        }
        
        XCTAssertNotNil(ss.categories, "Could not find the expected categories")
        XCTAssertTrue(ss.categories?.count ?? 0 > 0, "Could not find the expected categories")
    }
    
    func testGetTopCategories() {
        let ss = ShopSearch()
        let topCat = ss.getSortedCategories()
        XCTAssertNotNil(topCat, "Could not find the expected categories")
        
        for cat in topCat! {
            let subCat = ss.getSortedCategories(cat.categoryId)
            XCTAssertNotNil(subCat, "Could not find the expected categories")
            
            XCTAssertTrue(cat.children.count == subCat?.count, "Number of categories different than expected")
        }
    }
	
	func testGetCategoryById() {
		let ss = ShopSearch()
		var category = ss.getCategoryById(categoryId: "404")
		XCTAssertNotNil(category, "Could not find the expected category")
		
		category = ss.getCategoryById(categoryId: "401")
		XCTAssertNotNil(category, "Could not find the expected category")
		
		category = ss.getCategoryById(categoryId: "8")
		XCTAssertNotNil(category, "Could not find the expected category")
		
		category = ss.getCategoryById(categoryId: "1505")
		XCTAssertNotNil(category, "Could not find the expected category")
		
		category = ss.getCategoryById(categoryId: "1")
		XCTAssertNotNil(category, "Could not find the expected category")
	}
	
	func testGetCagetoryEmpty() {
		let ss = ShopSearch()
		var category = ss.getCategoryById(categoryId: "499")
		XCTAssertNil(category, "Could not find the expected category")
		
		category = ss.getCategoryById(categoryId: "909")
		XCTAssertNil(category, "Could not find the expected category")
		
	}
	
	func testGetCategoryPath() {
		let ss = ShopSearch()
		var path = ss.getCategoryPath(categoryId: "401")
		XCTAssertEqual(path, "Electronics > Video > Satellite & Cable TV > Satellite Receivers")
		
		path = ss.getCategoryPath(categoryId: "1505")
		XCTAssertEqual(path, "Electronics > Video Game Console Accessories > Home Game Console Accessories")
		
		path = ss.getCategoryPath(categoryId: "1")
		XCTAssertEqual(path, "Animals & Pet Supplies")
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
