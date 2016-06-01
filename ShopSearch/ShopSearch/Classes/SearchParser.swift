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
    func parserDidFinishSearch(product:[GoogleProduct])
    func parserDidFinishSearchWithError(message message:String)
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
    
    func parseProducts(onData data:NSData) -> [GoogleProduct] {
        
       let mainCategory = self.parseMainCategory(data)
        
        let elements = super.parseWithXPath(self.getXpathForElements(), onData: data)
        var products = [GoogleProduct]()
        
        for element in elements {
            
            //Reset parser Type
            self.parserType = .Type1
            
            let parsed = self.parseProductElement(element)
            
            if self.parserType  == .NoParserAvailable {
                continue
            }
            let product = GoogleProduct(productId: parsed.productId, title: parsed.title, googleLinkUrl: parsed.googleLinkUrl)
            product.category = mainCategory
            product.imageUrl = parsed.imageUrl
            product.price = parsed.price
            product.vendorName = parsed.vendorName
            product.descriptionProduct = parsed.descriptionProduct
            products.append(product)
            
        }
        
        return products
    }
    
    func parseProductElement(element: TFHppleElement) -> (imageUrl:String?, price:Double?, vendorName:String?, googleLinkUrl:String, productId:String, title:String, descriptionProduct:String?) {
    
        var imageUrl:String?
        var price:Double?
        var vendorName:String?
        var googleLinkUrl:String? = nil
        var productId:String? = nil
        var title:String? = nil
        var descriptionProduct:String? = nil
        
        while self.parserType != ParserType.NoParserAvailable && (title == nil || productId == nil || googleLinkUrl == nil) {
            
            switch self.parserType {
            case .Type1:
                
                let imgContainer = element.firstChildWithClassName("psliimg")
                if imgContainer != nil {
                    let img = imgContainer.firstChildWithTagName("a").firstChildWithTagName("img")
                    imageUrl = img.attributes["src"] as? String
                }
                
                let priceContainer = element.firstChildWithClassName("_OA")
                
                if priceContainer.children.count >= 1 {
                    
                    let priceTag = (priceContainer.children[0] as? TFHppleElement)?.firstChildWithTagName("b")
                    
                    price = Double(priceTag?.text().stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) ?? "")
                }
                
                if priceContainer.children.count >= 2 {
                    
                    let vendorTag = priceContainer.children[1] as? TFHppleElement
                    vendorName = vendorTag?.text()
                }
                
                let titleContainer = element.firstChildWithClassName("_AT")
                if titleContainer != nil {
                    let titleLink = titleContainer.firstChildWithClassName("r").firstChildWithTagName("a")
                    
                    if titleLink != nil {
                        googleLinkUrl = titleLink.attributes["href"] as? String
                        productId = self.getProductId(googleLinkUrl)
                        
                        title = self.stripHtmlTags(titleLink.raw)
                        
                        let descTag = titleContainer.firstChildWithTagName("div")
                        if descTag != nil {
                            descriptionProduct = self.stripHtmlTags(descTag.raw)
                        }
                    }
                }
            
            case .Type2, .Type3:
                break
            case .NoParserAvailable:
                NSLog("Could not parse the content for this product", "")
                break
            }//switch
            
            if title == nil || productId == nil || googleLinkUrl == nil {
                self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count)!
            }
        }//while
        
        return (imageUrl, price, vendorName, googleLinkUrl ?? "", productId ?? "", title ?? "", descriptionProduct)
    }
    
    func getXpathForElements() -> String {
        switch self.parserType {
        case .Type1, .Type2, .Type3:
            return "//html//*[@class=\"pslires\"]"
            
        case .NoParserAvailable:
            NSLog("No parser to get XPath", "")
            return ""
        }
    }
    
}

extension SearchParser: GoogleNetworkRequestDelegate {
    
    func googleRequestDidComplete(results:NSData?) {
        
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
