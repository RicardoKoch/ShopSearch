//
//  HtmlParser.swift
//  ShopSearch
//
//  Created by Ricardo Koch on 4/2/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import Foundation
import hpple

protocol HtmlParserDelegate: NSObjectProtocol {
    func parserDidFinishWorking(objects:[AnyObject])
}

class HtmlParser: NSObject {
    
    enum ParserType: Int {
        case Type1
        case Type2
        case Type3
        case NoParserAvailable
        
        static let all = [Type1, Type2, Type3, NoParserAvailable]
    }
    
    var parserType = ParserType.Type1

    var htmlData:NSData!
    weak var delegate: HtmlParserDelegate?
    
    func parseWithXPath(xPathQuery:String, onData data:NSData) -> [TFHppleElement] {
        
        self.htmlData = data
        let parser = TFHpple(HTMLData: self.htmlData)
        let elements = parser.searchWithXPathQuery(xPathQuery)
        return elements as? [TFHppleElement] ?? []
    }
    
    func parseMainCategory(data: NSData) -> GoogleCategory? {
        
        var catCode: String?
        while self.parserType != ParserType.NoParserAvailable && catCode == nil {
            
            let sideMenuLink:TFHppleElement?
            switch self.parserType {
            case .Type1:
                
                sideMenuLink = self.parseWithXPath("//html//a[@class=\"sr__bc-link\"]", onData: data).first
                break
            case .Type2:
                
                sideMenuLink = self.parseWithXPath("//html//*[@class=\"sr__group\"][2]/li[2]/a", onData: data).first
                break
            case .Type3:
                
                sideMenuLink = self.parseWithXPath("//html//div[@id=\"host-slice\"]/a", onData: data).first
            
            case .NoParserAvailable:
                NSLog("Could not parse the Category for this product", "")
                sideMenuLink = nil
                break
            }
            
            var href = sideMenuLink?.attributes["href"] as? String ?? ""
            href = href.stringByRemovingPercentEncoding ?? ""
            let queries = href.componentsSeparatedByString("&")
            
            for query in queries {
                if query.containsString("tbs=cat:") {
                    let r1 = query.rangeOfString("tbs=cat:")
                    let r2 = query.rangeOfString(",")
                    if let ur1 = r1, let ur2 = r2 {
                        catCode = query[ur1.endIndex ..< ur2.startIndex]
                    }
                    else if let ur1 = r1 {
                        catCode = query[ur1.endIndex ..< query.endIndex]
                    }
                    break
                }
            }
            
            if catCode == nil {
                self.parserType = ParserType(rawValue: (self.parserType.rawValue+1) % ParserType.all.count)!
            }
            
        }
        return ShopSearch.sharedInstance().categories?[catCode ?? ""]
    }
    
    func getProductId(urlPath:String?) -> String {
        return urlPath?.componentsSeparatedByString("?")[0].componentsSeparatedByString("/").last ?? ""
    }
    
    func stripHtmlTags(text:String) -> String {
        return text.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    }
    
    
}

