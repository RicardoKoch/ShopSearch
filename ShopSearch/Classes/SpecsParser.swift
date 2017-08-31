//
//  SpecsParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 8/6/17.
//  Copyright © 2017 Ricardo Koch. All rights reserved.
//

import Foundation
import hpple

protocol SpecsParserDelegate: HtmlParserDelegate {
	func parserDidFinishSpecs(_ specs:GoogleProductSpecs)
	func parserDidFinishSpecsWithError(message:String)
}


class SpecsParser: HtmlParser {

	weak var delegateInterceptor: SpecsParserDelegate?
	override var delegate: HtmlParserDelegate? {
		didSet {
			if let newValue = delegate as? SpecsParserDelegate {
				delegateInterceptor = newValue
			}
			else {
				delegateInterceptor = nil
			}
		}
	}
	
	var productId: String!
	
	func parseSpecs(onData data:Data) -> GoogleProductSpecs {
		
		let content = self.parseWithXPath("//div[@id=\"specs\"]", onData: data).first?.raw ?? ""
		let link = String(format: GoogleNetworkRequest.specs_format, GoogleNetworkRequest.google_domain, self.productId)
	
		return GoogleProductSpecs(htmlContent: content, linkUrl: link)
	}
}

extension SpecsParser: GoogleNetworkRequestDelegate {
	
	func googleRequestDidComplete(_ results:Data?) {
		
		let specs: GoogleProductSpecs?
		if results != nil {
			specs = self.parseSpecs(onData: results!)
		} else {
			specs = nil
		}
		
		if specs != nil {
			self.delegateInterceptor?.parserDidFinishSpecs(specs!)
		} else {
			self.delegateInterceptor?.parserDidFinishSpecsWithError(message: "No data parsed from source")
		}
	}
	
	func googleRequestDidFail() {
		self.delegateInterceptor?.parserDidFinishSpecsWithError(message: "Fail to parse data from source")
	}
	
}
