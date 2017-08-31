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
public typealias ShopCategoriesCallback = (([String:GoogleCategory]?, Bool) -> (Void))
public typealias ShopSearchCallback = (([GoogleProduct]?, Bool) -> (Void))
public typealias ShopProductCallback = ((GoogleProduct?, Bool) -> (Void))
public typealias ShopSpecsCallback = ((GoogleProductSpecs?, Bool) -> (Void))

public class ShopSearch: NSObject {

private static var __once: () = {
                ShopSearch.instance = ShopSearch()
            }()

//MARK: - Properties
    
    var networkRequester: GoogleNetworkRequest!
    var respondersQueue = Set<CallbackResponder>()
    var categories:[String:GoogleCategory]?
    var initialized = false
	
	//Set location code for customizing currency location
	public var locationCode: String?
    
//MARK: - Init
    
    private static var instance = ShopSearch()
    public static func shared() -> ShopSearch {
        return ShopSearch.instance
    }
    
    override init() {
        
        super.init()
        
        self.networkRequester = GoogleNetworkRequest()
        self.initializeCategories()
    }

//MARK: - Methods
//MARK: Public
    
    public func search(keywords words:String, completionBlock: @escaping ShopSearchCallback) {
        
        if words.characters.count == 0 {
            completionBlock([], true)
            return
        }
        
        if !waitForInit() {
            return
        }

        let parser = SearchParser()
        
        //init the responder
        let responder = CallbackResponder(withSearchCallback: completionBlock, parser: parser)
        self.respondersQueue.insert(responder)
        
        self.networkRequester.searchAdvRequest(words, parser: parser)
        
        disposeResponder(responder)
    }
    
    public func fetchProduct(_ productId:String, completionBlock: @escaping ShopProductCallback) {
        
        if productId.characters.count == 0 {
            completionBlock(nil, true)
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
	
	public func fetchSpecs(_ productId:String, completionBlock: @escaping ShopSpecsCallback) {
		
		if productId.characters.count == 0 {
			completionBlock(nil, true)
			return
		}
		
		if !waitForInit() {
			return
		}
		
		let parser = SpecsParser()
		parser.productId = productId
		
		//init the responder
		let responder = CallbackResponder(withSpecsCallback: completionBlock, parser: parser)
		self.respondersQueue.insert(responder)
		
		self.networkRequester.specsFetch(productId, parser: parser)
		
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
        return parent?.children.sorted(by: { $0.name < $1.name })
    }
	
	public func getCategoryById(categoryId: String) -> GoogleCategory? {
		if !waitForInit() {
			return nil
		}
		return self.categories?[categoryId]
	}
	
	public func getCategoryPath(categoryId: String) -> String {
		var path = ""
		var category = getCategoryById(categoryId: categoryId)
		while category != nil {
			path = (category?.name ?? "") + path
			category = category?.parent
			if category != nil {
				path = " > " + path
			}
		}
		return path
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
        
        let defaults = UserDefaults.standard
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
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
            
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
				RunLoop.main.run(until: Date().addingTimeInterval(0.1))
				self.respondersQueue.remove(responder)
			}
		}
    }
    
}
