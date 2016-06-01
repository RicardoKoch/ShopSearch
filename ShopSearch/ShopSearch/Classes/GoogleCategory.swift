//
//  GoogleCategory.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/5/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit

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
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.categoryId, forKey: "GoogleCategoryId")
        aCoder.encodeObject(self.name, forKey: "GoogleCategoryName")
        aCoder.encodeObject(self.parent, forKey: "GoogleCategoryParent")
        aCoder.encodeObject(self.children, forKey: "GoogleCategoryChildren")
    }
    
    convenience required public init?(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeObjectForKey("GoogleCategoryId") as! String
        let name = aDecoder.decodeObjectForKey("GoogleCategoryName") as! String
        let parent = aDecoder.decodeObjectForKey("GoogleCategoryParent") as? GoogleCategory
        let children = aDecoder.decodeObjectForKey("GoogleCategoryChildren") as? [GoogleCategory]
        
        self.init(withId:id, name:name)
        self.parent = parent
        self.children = children ?? []
    }
    
    public override var description: String {
        return "\(self.categoryId) - \(self.name)"
    }
    
}
