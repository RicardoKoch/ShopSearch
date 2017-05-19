//
//  ProductParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/4/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation
import hpple

protocol ProductParserDelegate: HtmlParserDelegate {
    func parserDidFinishProduct(_ product:GoogleProduct)
    func parserDidFinishProductWithError(message:String)
}

class ProductParser: HtmlParser {

    weak var delegateInterceptor: ProductParserDelegate?
    override var delegate: HtmlParserDelegate? {
        didSet {
            if let newValue = delegate as? ProductParserDelegate {
                delegateInterceptor = newValue
            }
            else {
                delegateInterceptor = nil
            }
        }
    }
    
    func parseProduct(onData data:Data) -> GoogleProduct? {
        
        let mainCategory = self.parseMainCategory(data)
		if mainCategory == nil {
			NSLog("no category", "")
		}
        
        //Reset parser Type
        self.parserType = .type1

        let product = self.parseProductElement(data)
        product?.category = mainCategory
		
        if product == nil {
            NSLog("No parser available for the Product", "")
        }
		
        return product
    }
    
    func parseProductElement(_ data: Data) -> GoogleProduct? {

		let product = GoogleProduct()
		var parseValid = false
		
        while self.parserType != ParserType.noParserAvailable && !parseValid {
            
            switch self.parserType {
            case .type1:
			
				parseValid = true
                let titleH1 = self.parseWithXPath("//h1[@id=\"product-name\"]", onData: data).first
				if let title = titleH1?.text() {
					product.title = title
				} else {
					parseValid = false
				}
				
                let priceSpan = self.parseWithXPath("//*[@id=\"summary-prices\"]//*[@class=\"price\"]", onData: data).first
				if let priceSpan = priceSpan {
				
					product.topPrice = priceSpan.text()
					
					let formatter = NumberFormatter()
					formatter.generatesDecimalNumbers = true
					formatter.numberStyle = NumberFormatter.Style.decimal
					if let formattedNumber = formatter.number(from: priceSpan.text().trimmingCharacters(in: CharacterSet.decimalDigits.inverted) ) as? NSDecimalNumber  {
						
						product.topPriceAmount = formattedNumber
					}
				}
				
                let imageImg = self.parseWithXPath("//*[@id=\"alt-image-cont\"]//img", onData: data).first
                product.imageUrl = imageImg?.attributes["src"] as? String
                
                let descripDiv = self.parseWithXPath("//*[@id=\"product-description-full\"]", onData: data).first
                product.descriptionProduct = descripDiv?.text() //self.stripHtmlTags(descTag.raw)
				
				
				let sellerNames = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@class=\"os-row\"]/td[@class=\"os-seller-name\"]/*[@class=\"os-seller-name-primary\"]/a", onData: data)
				
				var vendors = [GoogleVendor]()
				for nameNode in sellerNames {
					let link = nameNode.attributes["href"] as? String
					let vendor = GoogleVendor(name: nameNode.text(),
					                          linkUrl: link ?? "")
					vendors.append(vendor)
				}
				
				let formatter = NumberFormatter()
				formatter.numberStyle = .decimal
				
				let sellerBasePrices = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@class=\"os-row\"]/td[@class=\"os-price-col\"]/*[@class=\"os-base_price\"]", onData: data)
				for i in 0 ..< sellerBasePrices.count {
					let price = sellerBasePrices[i]
					vendors[i].basePrice = formatter.number(from: price.text().replacingOccurrences(of: "$", with: ""))
				}
				
				let sellerTotalPrices = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@class=\"os-row\"]/td[@class=\"os-total-col\"]", onData: data)
				for i in 0 ..< sellerTotalPrices.count {
					let price = sellerTotalPrices[i]
					vendors[i].totalPrice = formatter.number(from: price.text().replacingOccurrences(of: "$", with: "").trimmingCharacters(in: CharacterSet.whitespaces))
				}
				product.vendors = vendors

				//TODO:read review details
				
				//TODO:get more reviews link
				
				//TODO:get complete specs for the item (...4851024765336131874/specs?hl=en...)
				
				//get list of models and links for them
				var models = [GoogleProduct]()
				let optionModels = self.parseWithXPath("//div[@id=\"variant-container\"]/select[@id=\"variants\"]/option", onData:data)
				for option in optionModels {
					let link = option.attributes["href"] as? String
					if let link = link {
						models.append(GoogleProduct(productId: self.getProductId(link), title: option.text(), googleLinkUrl: link))
					}
				}
				product.models = models
				
				//get link and id
                let idLink = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@id=\"os-header\"]/th[@id=\"os-rating-col-th\"]/a", onData: data).first
				if let link = idLink?.attributes["href"] as? String {
					product.googleLinkUrl =  link
					product.productId = self.getProductId(product.googleLinkUrl)
				} else {
					parseValid = false
				}
				
			default:
                NSLog("Could not parse the content for this product", "")
            }//switch
            
			if !parseValid {
				self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count) ?? ParserType.noParserAvailable
			}
        }//while
        
        return product
    }

}

extension ProductParser: GoogleNetworkRequestDelegate {
    
    func googleRequestDidComplete(_ results:Data?) {
        
        let product: GoogleProduct?
        if results != nil {
            product = self.parseProduct(onData: results!)
        }
        else {
            product = nil
        }

        if product != nil {
            self.delegateInterceptor?.parserDidFinishProduct(product!)
        }
        else {
            self.delegateInterceptor?.parserDidFinishProductWithError(message: "No data parsed from source")
        }
    }
    
    func googleRequestDidFail() {
        
        self.delegateInterceptor?.parserDidFinishProductWithError(message: "Fail to parse data from source")
    }
    
}

