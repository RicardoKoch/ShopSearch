//
//  ShopSearch.swift
//  Pods
//
//  Created by Ricardo Koch on 3/29/16.
//
//

import UIKit
import hpple

//MARK: Constants
let InitializationTimeout:Int = 60
let CategoriesArchiveKey = "ShopSearch_CategoriesArchiveKey"
public typealias ShopCategoriesCallback = ((categories:[String:GoogleCategory]?, success:Bool) -> (Void))
public typealias ShopSearchCallback = ((products:[GoogleProduct]?, success:Bool) -> (Void))
public typealias ShopProductCallback = ((product:GoogleProduct?, success:Bool) -> (Void))

public class ShopSearch: NSObject {

private static var __once: () = {
                ShopSearch.instance = ShopSearch()
            }()

//MARK: - Properties
    
    var networkRequester: GoogleNetworkRequest!
    var respondersQueue = Set<CallbackResponder>()
    var categories:[String:GoogleCategory]?
    var initialized = false
    
//MARK: - Init
    
    internal static var instance: ShopSearch! = nil
    public static func sharedInstance() -> ShopSearch {
        if ShopSearch.instance == nil {
            var d = Int()
            _ = ShopSearch.__once
        }
        return ShopSearch.instance
    }
    
    override init() {
        
        super.init()
        
        self.networkRequester = GoogleNetworkRequest()
        self.initializeCategories()
    }

//MARK: - Methods
//MARK: Public
    
    public func search(keywords words:String, completionBlock: ShopSearchCallback) {
        
        if words.characters.count == 0 {
            completionBlock(products:[], success:true)
            return
        }
        
        if !waitForInit() {
            return
        }

        let parser = SearchParser()
        
        //init the responder
        let responder = CallbackResponder(withSearchCallback: completionBlock, parser: parser)
        self.respondersQueue.insert(responder)
        
        self.networkRequester.searchRequest(words, parser: parser)
        
        disposeResponder(responder)
    }
    
    public func fetchProduct(_ productId:String, completionBlock: ShopProductCallback) {
        
        if productId.characters.count == 0 {
            completionBlock(product:nil, success:true)
            return
        }
        
        if !waitForInit() {
            return
        }

        let parser = ProductParser()
        
        //init the responder
        let responder = CallbackResponder(withProductCallback: completionBlock, parser: parser)
        self.respondersQueue.insert(responder)
        
        self.networkRequester.productFetch(productId, parser: parser)
        
        disposeResponder(responder)
    }
    
    public func getSortedCategories() -> [GoogleCategory]? {
        return self.getSortedCategories("-1")
    }
    
    public func getSortedCategories(_ parentId:String) -> [GoogleCategory]? {
        
        if !waitForInit() {
            return nil
        }
        let parent = self.categories?[parentId]
        return parent?.children.sorted(isOrderedBefore: { $0.name < $1.name })
    }
    
//MARK: - Private
    
    func fetchCategories() {
        
        let parser = CategoriesParser()
        
        let responder = CallbackResponder(withCategoriesCallback: {
            (categories, success) in
            
            if success && categories != nil {
                self.categories = categories!
                self.initialized = true
            }
            
            }, parser: parser)
        
        self.respondersQueue.insert(responder)
        
        self.networkRequester.categoriesFetch(parser)
        
        disposeResponder(responder)
    }

    func initializeCategories() {
        
        let defaults = UserDefaults.standard()
        let encodedCategories = defaults.data(forKey: CategoriesArchiveKey)
        if let catData = encodedCategories {
            self.categories = NSKeyedUnarchiver.unarchiveObject(with: catData) as? [String:GoogleCategory]
        }
        if self.categories == nil {
            fetchCategories()
        }
        else {
            self.initialized = true
        }
    }
    
    func waitForInit() -> Bool {
        
        let sDate = Date()
        while !self.initialized {
            NSLog("WARNING: Framework not initialized, waiting for categories", "")
            RunLoop.main().run(until: Date().addingTimeInterval(0.1))
            
            if Int(Date().timeIntervalSince(sDate)) > InitializationTimeout {
                NSLog("Error: Timed-out waiting to initialize framework", "")
                return false
            }
        }
        return true
    }
    
    func disposeResponder(_ responder:CallbackResponder) {
		DispatchQueue.global().async {
			while(responder.finished == false) {
				//NSLog("Responder Waiting", "")
				Thread.sleep(forTimeInterval: 0.1)
				self.respondersQueue.remove(responder)
			}
		}
    }
    
}
