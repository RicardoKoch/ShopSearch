//
//  Product.swift
//  Pods
//
//  Created by Ricardo Koch on 4/2/16.
//
//

import UIKit

@objc public class GoogleProduct: NSObject {

	override init() {
		self.productId = ""
		self.title = ""
	}
	
    init(productId id:String, title:String, googleLinkUrl:String) {
        self.productId = id
        self.title = title
        super.init()
		self.googleLinkUrl = googleLinkUrl
    }
    
    public var productId: String
    public var category: GoogleCategory?
    public var imageUrl: String?
    public var price: Double?
    public var title: String
    public var descriptionProduct: String?
	
	private var _googleLinkUrl: String?
	public var googleLinkUrl: String {
		set (newValue) { _googleLinkUrl = GoogleNetworkRequest.google_domain + newValue }
		get { return _googleLinkUrl ?? "" }
	}

	/**
	* List of all vendors with this product for sell
	**/
	public var vendors = [GoogleVendor]()
	/**
	* List of alternative models for this product
	**/
	public var models = [GoogleProduct]()
	
    public override var description: String {
        return "\(self.productId):(\(self.category)) - \(title)"
    }
    
}

public struct GoogleVendor {
	init(name: String, linkUrl: String) {
		self.name = name
		self.linkUrl = linkUrl
	}
	public var name: String
	public var linkUrl: String
	public var basePrice: NSNumber?
	public var totalPrice: NSNumber?
}
