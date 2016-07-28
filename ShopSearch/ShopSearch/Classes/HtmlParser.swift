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
    func parserDidFinishWorking(_ objects:[AnyObject])
}

class HtmlParser: NSObject {
    
    enum ParserType: Int {
        case type1
        case type2
        case type3
        case noParserAvailable
        
        static let all = [type1, type2, type3, noParserAvailable]
    }
    
    var parserType = ParserType.type1

    var htmlData:Data!
    weak var delegate: HtmlParserDelegate?
    
    func parseWithXPath(_ xPathQuery:String, onData data:NSData) -> [TFHppleElement] {
        
        self.htmlData = data as Data!
        let parser = TFHpple(htmlData: self.htmlData)
        let elements = parser?.search(withXPathQuery: xPathQuery)
        return elements as? [TFHppleElement] ?? []
    }
    
    func parseMainCategory(_ data: Data) -> GoogleCategory? {
        
        var catCode: String?
        while self.parserType != ParserType.noParserAvailable && catCode == nil {
            
            let sideMenuLink:TFHppleElement?
            switch self.parserType {
            case .type1:
                
                sideMenuLink = self.parseWithXPath("//html//a[@class=\"sr__bc-link\"]", onData: data).first
                break
            case .type2:
                
                sideMenuLink = self.parseWithXPath("//html//*[@class=\"sr__group\"][2]/li[2]/a", onData: data).first
                break
            case .type3:
                
                sideMenuLink = self.parseWithXPath("//html//div[@id=\"host-slice\"]/a", onData: data).first
            
            case .noParserAvailable:
                NSLog("Could not parse the Category for this product", "")
                sideMenuLink = nil
                break
            }
            
            var href = sideMenuLink?.attributes["href"] as? String ?? ""
            href = href.removingPercentEncoding ?? ""
            let queries = href.components(separatedBy: "&")
            
            for query in queries {
                if query.contains("tbs=cat:") {
                    let r1 = query.range(of: "tbs=cat:")
                    let r2 = query.range(of: ",")
                    if let ur1 = r1, let ur2 = r2 {
                        catCode = query[ur1.upperBound ..< ur2.lowerBound]
                    }
                    else if let ur1 = r1 {
                        catCode = query[ur1.upperBound ..< query.endIndex]
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
    
    func getProductId(_ urlPath:String?) -> String {
        return urlPath?.components(separatedBy: "?")[0].components(separatedBy: "/").last ?? ""
    }
    
    func stripHtmlTags(_ text:String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: NSString.CompareOptions.regularExpressionSearch, range: nil)
    }
    
    
}

