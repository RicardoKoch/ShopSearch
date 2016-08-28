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
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
