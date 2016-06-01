//
//  Product.swift
//  Pods
//
//  Created by Ricardo Koch on 4/2/16.
//
//

import UIKit

public class GoogleProduct: NSObject {

    init(productId id:String, title:String, googleLinkUrl:String) {
        self.productId = id
        self.title = title
        self.googleLinkUrl = GoogleNetworkRequest.google_domain + googleLinkUrl
        super.init()
    }
    
    public var productId: String
    public var category: GoogleCategory?
    public var imageUrl: String?
    public var price: Double?
    public var title: String
    public var descriptionProduct: String?
    public var googleLinkUrl: String
    public var vendorLinkUrl: String?
    public var vendorName: String?
    
    public override var description: String {
        return "\(self.productId):(\(self.category)) - \(title)"
    }
    
}
