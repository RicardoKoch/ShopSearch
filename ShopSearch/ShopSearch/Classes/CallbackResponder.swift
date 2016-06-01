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
    
    init(withSearchCallback callback: ShopSearchCallback, parser: HtmlParser) {
        
        self.searchCallback = callback
        super.init()
        parser.delegate = self
    }
    
    init(withProductCallback callback: ShopProductCallback, parser: HtmlParser) {
        
        self.productCallback = callback
        super.init()
        parser.delegate = self
    }
    
    init(withCategoriesCallback callback: ShopCategoriesCallback, parser: HtmlParser) {
        
        self.categoriesCallback = callback
        super.init()
        parser.delegate = self
    }
    
    func runMT(block:((Void) -> (Void))) {
        dispatch_async(dispatch_get_main_queue(), {
            block()
        })
    }
    
}

extension CallbackResponder: HtmlParserDelegate {
    
    func parserDidFinishWorking(objects:[AnyObject]) {
        self.finished = true
    }
}

extension CallbackResponder: SearchParserDelegate {

    func parserDidFinishSearch(product:[GoogleProduct]) {
        runMT {
            self.searchCallback?(products: product, success: true)
        }
        
        self.finished = true
    }
    
    func parserDidFinishSearchWithError(message message:String) {
        runMT {
            self.searchCallback?(products: nil, success: false)
        }
        self.finished = true
    }
    
}

extension CallbackResponder: ProductParserDelegate {
    
    func parserDidFinishProduct(product:GoogleProduct) {
        runMT {
            self.productCallback?(product: product, success: true)
        }
        self.finished = true
    }
    
    func parserDidFinishProductWithError(message message:String) {
        runMT {
            self.productCallback?(product: nil, success: false)
        }
        self.finished = true
    }
    
}

extension CallbackResponder: CategoriesParserDelegate {
    
    func parserDidFinishCategories(categories:[String:GoogleCategory]) {
        runMT {
            self.categoriesCallback?(categories:categories, success:true)
        }
        self.finished = true
    }
    
    func parserDidFinishCategoriesWithError(message message:String) {
        runMT {
            self.categoriesCallback?(categories: nil, success: false)
        }
        self.finished = true
    }
    
}
