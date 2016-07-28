//
//  CategoriesParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/5/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit

protocol CategoriesParserDelegate: HtmlParserDelegate {
    func parserDidFinishCategories(_ categories:[String:GoogleCategory])
    func parserDidFinishCategoriesWithError(message:String)
}


class CategoriesParser: HtmlParser {

    
    weak var delegateInterceptor: CategoriesParserDelegate?
    override var delegate: HtmlParserDelegate? {
        didSet {
            if let newValue = delegate as? CategoriesParserDelegate {
                delegateInterceptor = newValue
            }
            else {
                delegateInterceptor = nil
            }
        }
    }
    
    func parseCategories(onData data:Data) -> [String:GoogleCategory]? {
        
        
        let str = String(data: data, encoding: String.Encoding.ascii) ?? ""
        
        var categories = [String:GoogleCategory]()
        var addedStack = [GoogleCategory]()

        let topParentCat = GoogleCategory(withId: "-1", name: "TOP")
        categories["-1"] = topParentCat
        
        let allCategories = str.components(separatedBy: "\n")
        let size = allCategories.count
        for i in 1 ..< size {

            let category = allCategories[i]
            let parts = category.components(separatedBy: " - ")
            if parts.count == 2 {
                
                let id = parts[0]
                let fullName = parts[1]
                
                let cat:GoogleCategory
                if fullName.range(of: " > ") != nil {
                    //This is a sub category.
                    let catNames = fullName.components(separatedBy: " > ")
                    let catName = catNames.last ?? ""
                    let parentName = catNames[catNames.count-2]
                    while addedStack.last?.name != parentName && addedStack.count > 0 {
                        addedStack.removeLast()
                    }
                    cat = GoogleCategory(withId: id, name: catName)
                    cat.parent = addedStack.last
                    addedStack.last?.children.append(cat)
                }
                else {
                    cat = GoogleCategory(withId: id, name: fullName)
                    topParentCat.children.append(cat) //Add child of top category to make fetch faster later
                }
                categories[id] = cat
                addedStack.append(cat)
            }
        }
        
        let defaults = UserDefaults.standard()
        let encodedCategories = NSKeyedArchiver.archivedData(withRootObject: categories)
        defaults.set(encodedCategories, forKey: CategoriesArchiveKey)
        
        return categories
    }
    
}


extension CategoriesParser: GoogleNetworkRequestDelegate {
    
    func googleRequestDidComplete(_ results:Data?) {
        
        let cat: [String:GoogleCategory]?
        if results != nil {
            cat = self.parseCategories(onData: results!)
        }
        else {
            cat = nil
        }
        
        if cat != nil {
            self.delegateInterceptor?.parserDidFinishCategories(cat!)
        }
        else {
            self.delegateInterceptor?.parserDidFinishCategoriesWithError(message: "No data parsed from source")
        }
    }
    
    func googleRequestDidFail() {
        
        self.delegateInterceptor?.parserDidFinishCategoriesWithError(message: "Fail to parse data from source")
    }
    
}
