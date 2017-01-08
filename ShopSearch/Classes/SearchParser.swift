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
            product.topVendor = parsed.vendorName
			product.setPriceTag()
            product.descriptionProduct = parsed.descriptionProduct
            products.append(product)
            
        }
        
        return products
    }
    
    func parseProductElement(_ element: TFHppleElement) -> (imageUrl:String?, price:NSNumber?, vendorName:String?, googleLinkUrl:String, productId:String, title:String, descriptionProduct:String?) {
    
        var imageUrl:String?
        var price:NSNumber?
        var vendorName:String?
        var googleLinkUrl:String? = nil
        var productId:String? = nil
        var title:String? = nil
        var descriptionProduct:String? = nil
        
        while self.parserType != ParserType.noParserAvailable && (title == nil || productId == nil || googleLinkUrl == nil) {
            
            switch self.parserType {
            case .type1:
                
                let imgContainer = element.firstChild(withClassName: "psliimg")
                if imgContainer != nil {
                    let img = imgContainer?.firstChild(withTagName: "a").firstChild(withTagName: "img")
                    imageUrl = img?.attributes["src"] as? String
                }
                
                let priceContainer = element.firstChild(withClassName: "_OA")
                
                if priceContainer?.children.count ?? 0 >= 1 {
                    
                    let priceTag = (priceContainer?.children[0] as? TFHppleElement)?.firstChild(withTagName: "b")
					
					let formatter = NumberFormatter()
					formatter.generatesDecimalNumbers = true
					formatter.numberStyle = NumberFormatter.Style.decimal
					if let formattedNumber = formatter.number(from: priceTag?.text().trimmingCharacters(in: CharacterSet.decimalDigits.inverted) ?? "") as? NSDecimalNumber  {
						price = formattedNumber
					}
                }
                
                if priceContainer?.children.count ?? 0 >= 2 {
                    
                    let vendorTag = priceContainer?.children[1] as? TFHppleElement
					if let tag = vendorTag {
						vendorName = tag.text()
					}
				}
					
                let titleContainer = element.firstChild(withClassName: "_AT")
                if titleContainer != nil {
                    let titleLink = titleContainer?.firstChild(withClassName: "r").firstChild(withTagName: "a")
                    
                    if titleLink != nil {
                        googleLinkUrl = titleLink?.attributes["href"] as? String
                        productId = self.getProductId(googleLinkUrl)
                        
                        title = self.stripHtmlTags((titleLink?.raw)!)
                        
                        let descTag = titleContainer?.firstChild(withTagName: "div")
                        if descTag != nil {
                            descriptionProduct = self.stripHtmlTags((descTag?.raw)!)
                        }
                    }
                }
            
            case .type2, .type3:
                break
            case .noParserAvailable:
                NSLog("Could not parse the content for this product", "")
                break
            }//switch
            
            if title == nil || productId == nil || googleLinkUrl == nil {
                self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count) ?? ParserType.noParserAvailable
            }
        }//while
        
        return (imageUrl, price, vendorName, googleLinkUrl ?? "", productId ?? "", title ?? "", descriptionProduct)
    }
    
    func getXpathForElements() -> String {
        switch self.parserType {
        case .type1, .type2, .type3:
            return "//html//*[@class=\"pslires\"]"
            
        case .noParserAvailable:
            NSLog("No parser to get XPath", "")
            return ""
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
