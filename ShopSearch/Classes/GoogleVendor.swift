//
//  GoogleVendor.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 8/6/17.
//  Copyright © 2017 Ricardo Koch. All rights reserved.
//

import Foundation

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
