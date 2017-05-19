//
//  SearchParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/2/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation
import hpple

protocol SearchParserDelegate: HtmlParserDelegate {
    func parserDidFinishSearch(_ product:[GoogleProduct])
    func parserDidFinishSearchWithError(message:String)
}

class SearchParser: HtmlParser {
 
    weak var delegateInterceptor: SearchParserDelegate?
    override var delegate: HtmlParserDelegate? {
        didSet {
            if let newValue = delegate as? SearchParserDelegate {
                delegateInterceptor = newValue
            }
            else {
                delegateInterceptor = nil
            }
        }
    }
    
    func parseProducts(onData data:Data) -> [GoogleProduct] {
        
       let mainCategory = self.parseMainCategory(data)
		if mainCategory == nil {
			NSLog("no category", "")
		}
		
		self.parserType = .type1
        let elements = super.parseWithXPath(self.getXpathForElements(), onData: data)
        var products = [GoogleProduct]()
        
        for element in elements {
            
            //Reset parser Type
            self.parserType = .type1
            
            let parsed = self.parseProductElement(element)
            
            if self.parserType  == .noParserAvailable {
                continue
            }
            let product = GoogleProduct(productId: parsed.productId, title: parsed.title, googleLinkUrl: parsed.googleLinkUrl)
            product.category = mainCategory
            product.imageUrl = parsed.imageUrl
            product.topPrice = parsed.price
			product.topPriceAmount = parsed.priceAmount
            product.topVendor = parsed.vendorName
			product.setPriceTag()
            product.descriptionProduct = parsed.descriptionProduct
            products.append(product)
            
        }
        
        return products
    }
    
	func parseProductElement(_ element: TFHppleElement) -> (imageUrl:String?, price: String?, priceAmount: NSNumber?, vendorName: String?, googleLinkUrl: String, productId: String, title: String, descriptionProduct: String?) {
    
        var imageUrl: String?
        var price: String?
		var priceAmount: NSNumber?
        var vendorName: String?
        var googleLinkUrl: String?
        var productId: String?
        var title: String?
        var descriptionProduct: String?
        
        while self.parserType != ParserType.noParserAvailable && (title == nil || productId == nil || googleLinkUrl == nil) {
            
            switch self.parserType {
            case .type1:
				
				let overlayContainer = element.children[1] as? TFHppleElement
				if overlayContainer != nil {
					let imgContainer = overlayContainer?.firstChild(withClassName: "psmliimg")
					if imgContainer != nil {
						let img = imgContainer?.firstChild(withTagName: "div").firstChild(withTagName: "img")
						imageUrl = img?.attributes["src"] as? String
					}
					if imgContainer?.children.count ?? 0 > 1, let cidElement = imgContainer?.children[1] as? TFHppleElement {
						productId = cidElement.attributes["data-cid"] as? String
						if productId?.characters.count ?? 0 == 0 {
							productId = cidElement.attributes["data-docid"] as? String
						}
					}
				}
				
				if let productId = productId {
					googleLinkUrl = String(format: GoogleNetworkRequest.product_format, GoogleNetworkRequest.google_domain, productId)
				}
				
                let priceContainer = element.children[2] as? TFHppleElement
				if let pc = priceContainer {
					title = stripHtmlTags( pc.firstChild(withTagName: "h3").firstChild(withTagName: "a").text() )
				}
				
                if priceContainer?.children.count ?? 0 >= 2 {
					
                    let vendorDiv = (priceContainer?.children[1] as? TFHppleElement)
					vendorName = vendorDiv?.text()
					
					var priceDiv = vendorDiv?.firstChild
					while (priceDiv != nil) {
						
						price = priceDiv?.content
						
						let formatter = NumberFormatter()
						formatter.generatesDecimalNumbers = true
						formatter.numberStyle = NumberFormatter.Style.decimal
						if let price = price, let formattedNumber = formatter.number(from: price.trimmingCharacters(in: CharacterSet.decimalDigits.inverted) ) as? NSDecimalNumber  {
							priceAmount = formattedNumber
							break
						}
						priceDiv = priceDiv?.firstChild
					}
					
                }
				
			default:
                NSLog("Could not parse the content for this product", "")
            }//switch
            
            if title == nil || productId == nil || googleLinkUrl == nil {
                self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count) ?? ParserType.noParserAvailable
            }
        }//while
        
        return (imageUrl, price, priceAmount, vendorName, googleLinkUrl ?? "", productId ?? "", title ?? "", descriptionProduct)
    }
    
    func getXpathForElements() -> String {
        switch self.parserType {
        case .noParserAvailable:
            NSLog("No parser to get XPath", "")
            return ""
		default:
			return "//html//*[@class=\"g psmli psmli-gf\"]"
        }
    }
    
}

extension SearchParser: GoogleNetworkRequestDelegate {
    
    func googleRequestDidComplete(_ results:Data?) {
        
        if results != nil {
            
            let products = self.parseProducts(onData: results!)
            
            self.delegateInterceptor?.parserDidFinishSearch(products)
            
        }
        else {
            self.delegateInterceptor?.parserDidFinishSearchWithError(message: "No data parsed from source")
        }
    }
    
    func googleRequestDidFail() {
        
        self.delegateInterceptor?.parserDidFinishSearchWithError(message: "Fail to parse data from source")
    }

}
