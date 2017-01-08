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
    public var topPrice: NSNumber?
	public var topVendor: String?
	public var priceTag: NSAttributedString?
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
	
	/**
	* Generate a price tag based on the list of vendors
	**/
	public func getPriceTag() -> NSAttributedString? {
		
		if vendors.count > 0 {
			var lowestPrice: Double? = vendors.first?.basePrice?.doubleValue
			for vendor in vendors {
				if let basePrice = vendor.basePrice?.doubleValue, (lowestPrice == nil || basePrice < lowestPrice!) {
					lowestPrice = basePrice
				}
			}
			let priceTag = NSMutableAttributedString()
			if let price = lowestPrice {
				
				let lowestPriceString = NSNumber(value:price).currencyString()
				let stringAttributes =
					[NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)]
				let priceAttr = NSAttributedString(string: lowestPriceString, attributes:stringAttributes)
				priceTag.append(priceAttr)
				
				priceTag.append(NSAttributedString(string:" from \(vendors.count) stores"))
				self.priceTag = priceTag
				return priceTag
			} else {
				return self.priceTag
			}
		} else {
			return self.priceTag
		}
	}
	
	internal func setPriceTag() {
		
		if let topPrice = self.topPrice, let topVendor = self.topVendor {
			let priceTag = NSMutableAttributedString()
			let lowestPriceString = topPrice.currencyString()
			let stringAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)]
			let priceAttr = NSAttributedString(string: lowestPriceString, attributes:stringAttributes)
			priceTag.append(priceAttr)
			priceTag.append(NSAttributedString(string:" \(topVendor)"))
			self.priceTag = priceTag
		}
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
