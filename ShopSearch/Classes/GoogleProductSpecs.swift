//
//  GoogleProductSpecs.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 8/6/17.
//  Copyright © 2017 Ricardo Koch. All rights reserved.
//

import Foundation

public struct GoogleProductSpecs {
	init(htmlContent: String, linkUrl: String) {
		self.htmlContent = htmlContent
		self.linkUrl = linkUrl
	}
	public var htmlContent: String
	public var linkUrl: String
}
