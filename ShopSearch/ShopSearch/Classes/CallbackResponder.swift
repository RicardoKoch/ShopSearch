//
//  CallbackResponder.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/4/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation

class CallbackResponder: NSObject {

    var searchCallback: ShopSearchCallback?
    var productCallback: ShopProductCallback?
    var categoriesCallback: ShopCategoriesCallback?
    var finished = false
    
    init(withSearchCallback callback: @escaping ShopSearchCallback, parser: HtmlParser) {
        
        self.searchCallback = callback
        super.init()
        parser.delegate = self
    }
    
    init(withProductCallback callback: @escaping ShopProductCallback, parser: HtmlParser) {
        
        self.productCallback = callback
        super.init()
        parser.delegate = self
    }
    
    init(withCategoriesCallback callback: @escaping ShopCategoriesCallback, parser: HtmlParser) {
        
        self.categoriesCallback = callback
        super.init()
        parser.delegate = self
    }
    
    func runMT(_ block:@escaping ((Void) -> (Void))) {
        DispatchQueue.main.async(execute: {
            block()
        })
    }
    
}

extension CallbackResponder: HtmlParserDelegate {
    
    func parserDidFinishWorking(_ objects:[AnyObject]) {
        self.finished = true
    }
}

extension CallbackResponder: SearchParserDelegate {

    func parserDidFinishSearch(_ product:[GoogleProduct]) {
        runMT {
            self.searchCallback?(product, true)
        }
        
        self.finished = true
    }
    
    func parserDidFinishSearchWithError(message:String) {
        runMT {
            self.searchCallback?(nil, false)
        }
        self.finished = true
    }
    
}

extension CallbackResponder: ProductParserDelegate {
    
    func parserDidFinishProduct(_ product:GoogleProduct) {
        runMT {
            self.productCallback?(product, true)
        }
        self.finished = true
    }
    
    func parserDidFinishProductWithError(message:String) {
        runMT {
            self.productCallback?(nil, false)
        }
        self.finished = true
    }
    
}

extension CallbackResponder: CategoriesParserDelegate {
    
    func parserDidFinishCategories(_ categories:[String:GoogleCategory]) {
        runMT {
            self.categoriesCallback?(categories, true)
        }
        self.finished = true
    }
    
    func parserDidFinishCategoriesWithError(message:String) {
        runMT {
            self.categoriesCallback?(nil, false)
        }
        self.finished = true
    }
    
}
