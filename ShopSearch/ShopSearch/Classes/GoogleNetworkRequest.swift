//
//  GoogleNetworkRequest.swift
//  Pods
//
//  Created by Ricardo Koch on 4/2/16.
//
//

import Foundation

@objc protocol GoogleNetworkRequestDelegate: class {
    @objc optional func googleRequestDidComplete(_ results:Data?)
    @objc optional func googleRequestDidFail()
}

class GoogleNetworkRequest: NSObject {
    
    static let google_domain = "https://www.google.com"
    
    static let search_format = "%@/search?hl=en&tbm=shop&tbs=vw:l&q=%@"
    static let product_format = "%@/shopping/product/%@?hl=en"
    
    //SOURCE: https://support.google.com/merchants/answer/160081?hl=en
    static let categories_format = "%@/basepages/producttype/taxonomy-with-ids.en-US.txt"
    
    var session: Foundation.URLSession!
    var dataMap = [Int: Data]()
    var parserMap = [Int: GoogleNetworkRequestDelegate]()
    
    override init() {

        super.init()
        
        let configuration = URLSessionConfiguration.default()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        self.session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        
    }
    
    deinit {
        self.session?.invalidateAndCancel()
    }
    
    func searchRequest(_ query:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.search_format, GoogleNetworkRequest.google_domain, query)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)

        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Search \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser

        dataTask.resume()
    }
    
    func productFetch(_ productId:String, parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.product_format, GoogleNetworkRequest.google_domain, productId)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        
        NSLog("Execute Product Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        
        dataTask.resume()
    }
    
    func categoriesFetch(_ parser:GoogleNetworkRequestDelegate) {
        
        var urlStr = String(format: GoogleNetworkRequest.categories_format, GoogleNetworkRequest.google_domain)
        urlStr = urlStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: urlStr)
        
        guard let urlUnwrap = url else {
            parser.googleRequestDidFail?()
            return
        }
        NSLog("Execute Categories Fetch \(urlUnwrap)", "")
        
        let dataTask = self.session.dataTask(with: urlUnwrap)
        self.parserMap[dataTask.taskIdentifier] = parser
        
        dataTask.resume()
    }

    
}

extension GoogleNetworkRequest: URLSessionDelegate {
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        //NSLog("didReceiveResponse", "")
        
        self.dataMap[dataTask.taskIdentifier] = Data()
        completionHandler(.allow)
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data){
        //NSLog("didReceiveData", "")
        self.dataMap[dataTask.taskIdentifier]?.append(data)
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        //NSLog("didCompleteWithError", "")
        
        //let str = String(data: self.responseData, encoding: NSASCIIStringEncoding)
       //NSLog(str!, "")
        if error == nil {
            let data = self.dataMap[task.taskIdentifier]
            
            self.parserMap[task.taskIdentifier]?.googleRequestDidComplete?(data)
        }
        else {
            self.parserMap[task.taskIdentifier]?.googleRequestDidFail?()
        }
        self.dataMap[task.taskIdentifier] = nil
        self.parserMap[task.taskIdentifier] = nil
    }
    
    
    
}

