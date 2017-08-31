//
//  GoogleCategory.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/5/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation

public class GoogleCategory: NSObject, NSCoding  {

    public var categoryId: String
    public var name: String
    public weak var parent: GoogleCategory?
    public var children = [GoogleCategory]()
    
    init(withId id:String, name:String) {
        self.categoryId = id
        self.name = name
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.categoryId, forKey: "GoogleCategoryId")
        aCoder.encode(self.name, forKey: "GoogleCategoryName")
        aCoder.encode(self.parent, forKey: "GoogleCategoryParent")
        aCoder.encode(self.children, forKey: "GoogleCategoryChildren")
    }
    
    convenience required public init?(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeObject(forKey: "GoogleCategoryId") as! String
        let name = aDecoder.decodeObject(forKey: "GoogleCategoryName") as! String
        let parent = aDecoder.decodeObject(forKey: "GoogleCategoryParent") as? GoogleCategory
        let children = aDecoder.decodeObject(forKey: "GoogleCategoryChildren") as? [GoogleCategory]
        
        self.init(withId:id, name:name)
        self.parent = parent
        self.children = children ?? []
    }
    
    public override var description: String {
        return "\(self.categoryId) - \(self.name)"
    }
    
}
