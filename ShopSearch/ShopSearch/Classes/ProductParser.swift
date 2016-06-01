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
    func parserDidFinishProduct(product:GoogleProduct)
    func parserDidFinishProductWithError(message message:String)
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
    
    func parseProduct(onData data:NSData) -> GoogleProduct? {
        
        let mainCategory = self.parseMainCategory(data)
        
        //Reset parser Type
        self.parserType = .Type1

        let parsed = self.parseProductElement(data)
        
        if self.parserType  == .NoParserAvailable {
            NSLog("No parser available for the Product", "")
            return nil
        }
        let product = GoogleProduct(productId: parsed.productId, title: parsed.title, googleLinkUrl: parsed.googleLinkUrl)
        product.category = mainCategory
        product.imageUrl = parsed.imageUrl
        product.price = parsed.price
        product.vendorName = parsed.vendorName
        product.vendorLinkUrl = parsed.vendorLinkUrl
        product.descriptionProduct = parsed.descriptionProduct
        
        return product
    }
    
    func parseProductElement(data: NSData) -> (imageUrl:String?, price:Double?, vendorName:String?, googleLinkUrl:String, productId:String, title:String, descriptionProduct:String?, vendorLinkUrl:String?) {
        
        var imageUrl:String?
        var price:Double?
        var vendorName:String?
        var vendorLinkUrl:String?
        var googleLinkUrl:String? = nil
        var productId:String? = nil
        var title:String? = nil
        var descriptionProduct:String? = nil
        
        while self.parserType != ParserType.NoParserAvailable && (title == nil || productId == nil || googleLinkUrl == nil) {
            
            switch self.parserType {
            case .Type1:
                
                
                let titleH1 = self.parseWithXPath("//h1[@id=\"product-name\"]", onData: data).first
                title = titleH1?.text()
                
                let priceSpan = self.parseWithXPath("//*[@id=\"summary-prices\"]//*[@class=\"price\"]", onData: data).first
                price = Double(priceSpan?.text().stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) ?? "")
                
                let imageImg = self.parseWithXPath("//*[@id=\"alt-image-cont\"]//img", onData: data).first
                imageUrl = imageImg?.attributes["src"] as? String
                
                let descripDiv = self.parseWithXPath("//*[@id=\"product-description-full\"]", onData: data).first
                descriptionProduct = descripDiv?.text() //self.stripHtmlTags(descTag.raw)
                
                //TODO: Support all vendors. We now only support the first one
                //let sellerRows = self.parseWithXPath("//*[@id=\"os-sellers-table\"]///tr[@class=\"os-row\"]", onData: data)
                
                let firstSellerLink = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@class=\"os-row\"]/td[@class=\"os-seller-name\"]/*[@class=\"os-seller-name-primary\"]/a", onData: data).first
                vendorLinkUrl = firstSellerLink?.attributes["href"] as? String
                vendorName = firstSellerLink?.text()
                
                let idLink = self.parseWithXPath("//*[@id=\"os-sellers-table\"]/tr[@id=\"os-header\"]/th[@id=\"os-rating-col-th\"]/a", onData: data).first
                googleLinkUrl = idLink?.attributes["href"] as? String
                productId = self.getProductId(googleLinkUrl)
                
             
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
        
        return (imageUrl, price, vendorName, googleLinkUrl ?? "", productId ?? "", title ?? "", descriptionProduct, vendorLinkUrl)
    }

}

extension ProductParser: GoogleNetworkRequestDelegate {
    
    func googleRequestDidComplete(results:NSData?) {
        
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

