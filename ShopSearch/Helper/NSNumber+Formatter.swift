//
//  NSNumber+Formatter.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 1/7/17.
//  Copyright © 2017 Ricardo Koch. All rights reserved.
//

import UIKit

extension NSNumber {
	
	func currencyString() -> String {
		
		//currency formater
		let nFormatter = NumberFormatter()
		nFormatter.numberStyle = NumberFormatter.Style.currency
		if let code = ShopSearch.shared().locationCode {
			nFormatter.locale = Locale(identifier: code)
		} else {
			nFormatter.locale = Locale.current
		}
		return nFormatter.string(from: self) ?? ""
	}
	
}
